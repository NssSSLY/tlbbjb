#pragma once
#include "game_snippets.hpp"
#include <cstdint>
#include <memory>
#include <string>
#include <vector>
namespace tlbb::resident {
struct Value {
    enum Kind{Nil,Number,Boolean,Text} kind=Nil;double number=0;std::string text;
    Value()=default;Value(double n):kind(Number),number(n){};Value(int n):Value(double(n)){}
    Value(bool b):kind(Boolean),number(b?1:0){};Value(std::string s):kind(Text),text(std::move(s)){}
};
using Values=std::vector<Value>;
struct Object {int id=-1,server=-1;double x=0,y=0,hp=0;bool hostile=false;std::string name;double distance=0;};
struct Host {
    virtual ~Host()=default;
    virtual Values snippet(uint32_t,const gameplay::SnippetArgs&)=0;
    virtual Values call(const std::string&,const std::string&)=0;
    virtual Values evaluate(const std::string&,const std::string&,int)=0;
    virtual std::vector<Object> objects()=0;
    virtual void log(const std::string&)=0;
};
class Vm {
public:
    enum State{Idle,Running,Sleeping,Paused,Completed,Failed,Stopped};
    explicit Vm(Host &, bool offlineDiagnostics=false);~Vm();
    bool start(const std::string &source,std::string &error);
    void step(uint64_t activeMilliseconds);
    void pause(bool value);void stop();
    State state()const;size_t allocated()const;uint64_t calls()const;
    const std::string &error()const;
private:struct Impl;std::unique_ptr<Impl> p_;
};
}
