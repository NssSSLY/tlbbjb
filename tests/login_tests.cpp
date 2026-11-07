#include "login_client.hpp"
#include "client_store.hpp"
#include "official_launcher.hpp"
#include "game_text.hpp"
#include "login_password_input.hpp"
#include <QFile>
#include <QDir>
#include <QJsonArray>
#include <QJsonDocument>
#include <QTemporaryDir>
#include <stdexcept>
namespace tlbb {
int runLoginTests(const QString &root,const QString &report){
    QJsonArray checks;QString failure;
    auto require=[](bool ok,const char *message){if(!ok)throw std::runtime_error(message);};
    try{
        wchar_t decoded[65]{};
        const auto nickname=QByteArray(u8"角色·测试🌾");
        require(decodeCeguiUtf8(nickname.constData(),nickname.size(),decoded,65)&&QString::fromWCharArray(decoded)==QString::fromUtf8(nickname),"CEGUI Unicode role name corrupted");
        require(!decodeCeguiUtf8("\xc0\xaf",2,decoded,65)&&!decoded[0],"Malformed UTF-8 was cached");
        require(!decodeCeguiUtf8(nickname.constData(),nickname.size(),decoded,3)&&!decoded[0],"Truncated role name accepted");
        require(decodeCeguiUtf8("",0,decoded,65)&&!decoded[0],"Empty role name failed");
        checks.append("CEGUI role names decode strict UTF-8 with Chinese and supplementary characters; invalid/truncated data is rejected atomically");
        QDir().mkpath(root+"/artifacts/login-tests");QTemporaryDir migration(root+"/artifacts/login-tests/names-XXXXXX");
        require(migration.isValid(),"Nickname migration fixture failed");QString migrationError;
        QJsonObject legacy{{"schema",3},{"selected_account","fixture"},{"accounts",QJsonArray{QJsonObject{{"id","fixture"},{"credential_ref","fixture"},{"slot",2},{"destinations",QJsonObject{{"area/server",QJsonObject{{"roles",QJsonObject{{"1","legacy-name"}}}}}}}}}}};
        require(ClientStore::writeJson(migration.path()+"/launcher.json",legacy,migrationError),"Legacy fixture write failed");
        ClientStore repaired(migration.path());require(repaired.load(migrationError),"Nickname migration failed");
        auto repairedAccount=repaired.launcher.value("accounts").toArray()[0].toObject();
        require(repairedAccount.value("slot")==2&&repairedAccount.value("credential_ref")=="fixture","Migration changed account selection or credential reference");
        require(repairedAccount.value("destinations").toObject().value("area/server").toObject().value("roles").toObject().isEmpty(),"Old name codec cache survived");
        require(QDir(migration.path()+"/migrations").entryList({"*.json"},QDir::Files).size()==1,"Original name cache was not backed up");
        repairedAccount=ClientStore::rememberRole(repairedAccount,"area","server",1,QString::fromUtf8(u8"中文角色"));
        repaired.launcher.insert("accounts",QJsonArray{repairedAccount});require(repaired.save(migrationError)&&repaired.load(migrationError),"UTF-8 cache reload failed");
        require(repaired.launcher.value("accounts").toArray()[0].toObject().value("destinations").toObject().value("area/server").toObject().value("roles").toObject().value("1")==QString::fromUtf8(u8"中文角色"),"Verified UTF-8 name was invalidated");
        checks.append("Legacy role-name cache is backed up and invalidated without changing account/slot/credential references; UTF-8 cache survives reload");
        LoginFlow flow;
        require(flow.next(login::Loading)==0,"boot must wait");require(flow.next(login::Server)==login::SelectServer,"server selection missing");flow.issued(login::SelectServer);require(flow.next(login::Server)==0,"server command repeated");
        require(flow.next(login::Account)==login::SubmitAccount,"credential command missing");flow.issued(login::SubmitAccount);for(int i=0;i<300;++i)require(flow.next(login::Account)==0,"password submitted again");checks.append("Each server and credential command is issued once");
        QByteArray typed;size_t inputLength=0;
        auto capture=[&](unsigned char c){typed.append(char(c));return true;};
        require(login::sendPasswordInput("012345",7,capture)&&typed=="012345","secure password input did not send characters in order");
        typed.clear();require(!login::sendPasswordInput("",1,capture)&&typed.isEmpty(),"empty secure password was sent");
        const QByteArray tooLong(33,'7');require(!login::sendPasswordInput(tooLong.constData(),size_t(tooLong.size()+1),capture)&&typed.isEmpty(),"oversized password was partially sent");
        const QByteArray nonAscii=QString::fromUtf8(u8"测试").toUtf8();require(!login::sendPasswordInput(nonAscii.constData(),size_t(nonAscii.size()+1),capture)&&typed.isEmpty(),"non-ASCII password was partially sent");
        const QByteArray maxLength(32,'8');require(login::validPasswordInput(maxLength.constData(),size_t(maxLength.size()+1),inputLength)&&inputLength==32,"maximum password length rejected");
        checks.append("Secure password input sends six synthetic digits in order and rejects invalid input before sending");
        for(int i=0;i<300;++i)require(flow.next(login::Manual)==0,"manual validation must wait");
        require(flow.next(login::Roles)==login::SelectRole,"role stage did not resume");flow.issued(login::SelectRole);require(flow.next(login::Roles)==login::EnterWorld,"enter command missing");flow.issued(login::EnterWorld);require(flow.next(login::Roles)==0,"enter command repeated");checks.append("Human verification pauses and resumes without credential retries");
        require(flow.next(login::World)==0,"one sample is insufficient");require(flow.next(login::Loading)==0,"loading must interrupt samples");require(flow.next(login::World)==0&&flow.next(login::World)==-1,"world samples not confirmed");checks.append("Success requires entry command and two consecutive world samples");
        LoginFlow existing;require(existing.next(login::World)==-2&&existing.next(login::Roles)==-2,"existing game must not be authenticated");require(existing.next(login::Account)==login::BackToServer,"unverified server must go back");existing.issued(login::BackToServer);require(existing.next(login::Account)==0,"back navigation repeated");checks.append("Pre-existing online games and unverified server selection do not receive credentials");
        QDir().mkpath(root+"/artifacts/login-tests");QTemporaryDir temporary(root+"/artifacts/login-tests/owned-XXXXXX");require(temporary.isValid(),"temporary fixture failed");ClientStore store(temporary.path());QString error;QByteArray secret;
        require(!store.readPassword("missing",secret,error)&&secret.isEmpty(),"missing credential accepted");require(store.savePassword("owned-fixture","fixture-only-password-0123",error),"DPAPI encryption failed");require(store.readPassword("owned-fixture",secret,error)&&secret=="fixture-only-password-0123","DPAPI round trip failed");SecureZeroMemory(secret.data(),SIZE_T(secret.size()));secret.clear();
        const QStringList passwordFixtures={QStringLiteral("Test!@#$%^&*()_+-=[]{}|;:'\",.<>?/\\~"),QString::fromUtf8(u8"测试密码-123")};
        for(int i=0;i<passwordFixtures.size();++i){
            const auto fixtureId=QString("owned-symbols-%1").arg(i);
            require(store.savePassword(fixtureId,passwordFixtures[i],error),"fixture password save failed");
            require(store.readPassword(fixtureId,secret,error)&&secret==passwordFixtures[i].toUtf8(),"fixture password characters changed during save/load");
            SecureZeroMemory(secret.data(),SIZE_T(secret.size()));secret.clear();
        }
        checks.append("Synthetic punctuation and Unicode password storage round trips without reading user credentials");
        auto path=temporary.path()+"/credentials/"+ClientStore::roleKey({{"account","owned-fixture"}})+".dat";QFile file(path);require(file.open(QIODevice::ReadWrite),"cannot inspect fixture");auto encrypted=file.readAll();require(!encrypted.contains("fixture-only-password-0123"),"plaintext was persisted");encrypted[encrypted.size()/2]^=0x55;file.seek(0);file.write(encrypted);file.close();require(!store.readPassword("owned-fixture",secret,error)&&secret.isEmpty(),"corrupt credential accepted");checks.append("DPAPI encrypt/decrypt succeeds; missing and tampered credentials fail without plaintext output");
        require(sizeof(login::Packet)<4096,"IPC packet grew without bound");require(login::Packet{}.command==login::Query,"default command must be read-only");checks.append("Login IPC has a bounded payload and defaults to a read-only query");
        require(login::sameDistrict(L"网通-华北网通一区",L"网通华北网通一区"),"legacy district separator rejected");require(!login::sameDistrict(L"网通-华北网通一区",L"网通-华北网通二区"),"different districts conflated");checks.append("Legacy district separator is compatible; different district names remain distinct");
        login::Packet timed;require(login::cancelPending(timed)&&timed.status==login::Cancelled&&timed.error==WAIT_TIMEOUT,"timeout misreported as rejection zero");require(InterlockedCompareExchange(&timed.status,login::Executing,login::Pending)==login::Cancelled,"late callback claimed a cancelled request");require(login::transientQueryFailure(timed),"query timeout cannot wait for game startup");timed.command=login::SubmitAccount;require(!login::transientQueryFailure(timed),"account submission would be replayed");checks.append("Startup query timeout is distinct from rejection and a cancelled request cannot execute later");
        login::Packet denied;require(login::cancelPending(denied,ERROR_ACCESS_DENIED)&&!login::transientQueryFailure(denied),"permission failure would be retried");login::Packet executing;executing.status=login::Executing;require(!login::cancelPending(executing)&&executing.status==login::Executing,"cancel changed an executing callback");checks.append("Permission failures stop and an executing callback retains ownership of its mapping");
        require(ClientStore::loginFingerprint(" OwnedFixture ")==ClientStore::loginFingerprint("ownedfixture@sohu.com"),"protected account spelling changed fingerprint");require(ClientStore::loginFingerprint("ownedfixture")!=ClientStore::loginFingerprint("otherfixture"),"different test accounts conflated");checks.append("Protected login account guard recognizes case and email spellings without storing a clear identifier in diagnostics");
        login::Packet expired;expired.status=login::Rejected;expired.error=WAIT_TIMEOUT;require(login::transientQueryFailure(expired),"expired startup query cannot wait");expired.command=login::SubmitAccount;require(!login::transientQueryFailure(expired),"expired account action would be resent");expired.command=login::Query;expired.error=ERROR_INVALID_DATA;require(!login::transientQueryFailure(expired),"invalid process or thread identity would be retried");checks.append("An expired read-only callback can recover while identity failures and account actions cannot be replayed");
        QPoint point;require(officialSkinPoint(1470,787,point)&&point==QPoint(1343,608),"Official shared skin point mismatch");require(officialSkinPoint(650,414,point)&&point==QPoint(577,301),"Official alternate skin point mismatch");require(officialSkinPoint(2940,1574,point)&&point==QPoint(2686,1216),"DPI scale mismatch");require(!officialSkinPoint(800,600,point)&&!officialSkinPoint(0,0,point),"Unrelated window accepted as official skin");checks.append("Hash-locked public skin geometry supports exact and DPI-scaled layouts and refuses unrelated windows");
    }catch(const std::exception &e){failure=QString::fromUtf8(e.what());}
    QString error;ClientStore::writeJson(report,{{"status",failure.isEmpty()?"pass":"fail"},{"checks",checks},{"error",failure},{"real_account_submitted",false}},error);
    return failure.isEmpty()&&error.isEmpty()?0:1;
}
}
