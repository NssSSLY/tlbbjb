#include "builtin_resources.hpp"
#include <QCoreApplication>
#include <QCryptographicHash>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonArray>
#include <QJsonDocument>
#include <QResource>
#include <QSet>
namespace tlbb {
namespace {
QJsonObject manifest;
bool mounted=false;
QString key(const QString &requested){
    QString p=QDir::fromNativeSeparators(requested),base=QCoreApplication::applicationDirPath()+"/";
    if(p.startsWith(":/tlbb/"))p.remove(0,7);
    else if(p.startsWith(base+"overrides/",Qt::CaseInsensitive))p.remove(0,base.size()+10);
    else if(p.startsWith(base,Qt::CaseInsensitive))p.remove(0,base.size());
    else if(QFileInfo(p).isAbsolute())return {};
    if(p!=QDir::cleanPath(p)||p.contains('\\')||p.contains(':')||p.startsWith("../"))return {};
    return p=="scripts/builtin"||p.startsWith("scripts/builtin/")||p=="tasks"||p.startsWith("tasks/")?p:QString();
}
QStringList locations(const QString &requested){
    const auto k=key(requested);if(k.isEmpty())return {requested};
    const auto base=QCoreApplication::applicationDirPath()+"/";
    // Packaged releases keep every rule file loose under scripts/, the catalog included.
    return {base+"overrides/"+k,":/tlbb/"+k,base+(k.startsWith("tasks/")||k=="tasks"?"scripts/"+k:k)};
}
bool beneath(const QString &base,const QString &file){
    const auto root=QDir(base).canonicalPath(),p=QFileInfo(file).canonicalFilePath();
    return !root.isEmpty()&&!p.isEmpty()&&p.startsWith(root+"/",Qt::CaseInsensitive);
}
}
bool BuiltinResources::mount(QString &error){
    error.clear();if(mounted)return true;
    const auto file=QCoreApplication::applicationDirPath()+"/TLBBData.rcc";
    if(!QFileInfo::exists(file))return true; // Older loose-file releases remain readable.
    if(!QResource::registerResource(file)){error="TLBBData.rcc 无效，无法加载内置脚本";return false;}
    auto reject=[&]{QResource::unregisterResource(file);error="内置资源清单或哈希不符，请重新构建 TLBBData.rcc";return false;};
    QFile index(":/tlbb/assets-manifest.json");
    if(!index.open(QIODevice::ReadOnly)||index.size()>256*1024)return reject();
    const auto m=QJsonDocument::fromJson(index.readAll()).object();const auto entries=m.value("files").toArray();
    if(m.value("schema").toInt()!=1||m.value("kind").toString()!="tlbb_resources"||entries.isEmpty()||entries.size()>1024)return reject();
    QSet<QString> names;qsizetype total=0;
    for(const auto &v:entries){const auto o=v.toObject();const auto name=o.value("path").toString();
        if(key(name)!=name||names.contains(name))return reject();
        names.insert(name);
        QFile asset(":/tlbb/"+name);if(!asset.open(QIODevice::ReadOnly)||asset.size()<0||asset.size()>2*1024*1024||asset.size()!=o.value("bytes").toInt(-1))return reject();
        total+=asset.size();if(total>24*1024*1024)return reject();
        QCryptographicHash h(QCryptographicHash::Sha256);if(!h.addData(&asset)||h.result().toHex()!=o.value("sha256").toString().toLatin1())return reject();
    }
    manifest=m;mounted=true;return true;
}
QString BuiltinResources::path(const QString &requested){
    for(const auto &p:locations(requested))if(QFileInfo(p).isFile())return p;
    return requested;
}
QString BuiltinResources::child(const QString &directory,const QString &relative){
    if(relative.isEmpty()||QFileInfo(relative).isAbsolute()||relative!=QDir::cleanPath(relative)||relative.contains(':')||relative.contains('\\')||relative.startsWith("../"))return {};
    const auto file=path(directory+"/"+relative);
    for(const auto &root:locations(directory))if(beneath(root,file))return QFileInfo(file).canonicalFilePath();
    return {};
}
QStringList BuiltinResources::files(const QString &directory,const QString &filter){
    QSet<QString> names;
    for(const auto &dir:locations(directory))for(const auto &name:QDir(dir).entryList({filter},QDir::Files))names.insert(name);
    auto list=names.values();list.sort();QStringList result;
    for(const auto &name:list){const auto p=child(directory,name);if(!p.isEmpty())result.append(p);}return result;
}
QJsonObject BuiltinResources::report(){
    auto result=manifest;result.insert("mounted",mounted);
    result.insert("loose_scripts",!mounted&&QFileInfo::exists(QCoreApplication::applicationDirPath()+"/scripts/builtin/legacy/manifest.json"));
    QJsonArray overrides;
    const auto prefix=QCoreApplication::applicationDirPath()+"/overrides/";
    for(const auto &v:manifest.value("files").toArray()){
        const auto name=v.toObject().value("path").toString();const auto p=path(name);
        if(p.startsWith(prefix,Qt::CaseInsensitive)){QFile f(p);if(f.open(QIODevice::ReadOnly)&&f.size()<=2*1024*1024){QCryptographicHash h(QCryptographicHash::Sha256);if(h.addData(&f))overrides.append(QJsonObject{{"path",name},{"sha256",QString::fromLatin1(h.result().toHex())}});}}
    }
    result.insert("overrides",overrides);
    QFile file(QCoreApplication::applicationDirPath()+"/TLBBData.rcc");
    if(file.open(QIODevice::ReadOnly)){QCryptographicHash h(QCryptographicHash::Sha256);if(h.addData(&file))result.insert("bundle_sha256",QString::fromLatin1(h.result().toHex()));result.insert("bundle_bytes",double(file.size()));}
    return result;
}
}
