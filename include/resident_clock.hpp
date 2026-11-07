#pragma once
#include <cstdint>
namespace tlbb::resident {
// Timing policy of the in-game task manager, free of Windows and the VM so it is tested offline.
// The controller lease runs on real time (a vanished controller stops the task even while paused);
// the task timeout counts running time only, so a pause never uses it up.
struct Clock {
    enum Step { Run, Paused, Disconnected, TimedOut };
    uint64_t last=0,active=0,lease=0;uint32_t timeout=600;
    void start(uint64_t now,uint32_t seconds){last=lease=now;active=0;timeout=seconds;}
    void renew(uint64_t now){lease=now;}   // every controller request
    void resume(uint64_t now){last=now;}   // the paused interval is not counted
    Step step(uint64_t now,bool ownerAlive,bool paused){
        const auto delta=now-last;last=now;
        if(!ownerAlive||now-lease>5000)return Disconnected;
        if(paused)return Paused;
        active+=delta;
        return active>uint64_t(timeout)*1000?TimedOut:Run;
    }
};
}
