#pragma once
#include "login_protocol.hpp"
#include <QStringList>
#include <QJsonObject>
namespace tlbb {
class LoginFlow {
  public:
    bool serverSent=false,credentialsSent=false,roleSent=false,enterSent=false,backSent=false;
    int worldSamples=0;
    // 0 wait, -1 complete, -2 stop; otherwise an allowlisted bridge command.
    int next(login::Stage stage){
        if(stage!=login::World)worldSamples=0;
        if(stage==login::World)return enterSent?(++worldSamples>=2?-1:0):-2;
        if(stage==login::Server)return serverSent?0:int(login::SelectServer);
        if(stage==login::Account){if(!serverSent)return backSent?0:int(login::BackToServer);return credentialsSent?0:int(login::SubmitAccount);}
        if(stage==login::Roles){if(!credentialsSent)return -2;if(!roleSent)return login::SelectRole;if(!enterSent)return login::EnterWorld;}
        return 0;
    }
    void issued(int command){if(command==login::SelectServer)serverSent=true;else if(command==login::SubmitAccount)credentialsSent=true;else if(command==login::SelectRole)roleSent=true;else if(command==login::EnterWorld)enterSent=true;else if(command==login::BackToServer)backSent=true;}
};
int runLoginWorker(const QStringList &arguments);
int runLoginTests(const QString &root,const QString &report);
}
