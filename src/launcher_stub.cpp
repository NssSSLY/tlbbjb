// TLBB.exe in a packaged release: no Qt, no runtime DLLs of its own. It unpacks TLBBRuntime.dll (the app, Qt and the compiler runtime)
// into data\cache once per version and runs the app inside this process, so the program's own folder stays the install folder.
#include <windows.h>
#include <shellapi.h>
#include <cstdint>
#include <cstring>
#include <string>
#include <vector>

namespace {
void fail(const std::wstring &text){MessageBoxW(nullptr,text.c_str(),L"TLBB 启动失败",MB_OK|MB_ICONERROR);}
std::wstring widen(const char *s,size_t n){
    const int size=MultiByteToWideChar(CP_UTF8,0,s,int(n),nullptr,0);std::wstring out(size_t(size),L'\0');
    MultiByteToWideChar(CP_UTF8,0,s,int(n),out.data(),size);return out;
}
bool makeDirs(const std::wstring &path){
    for(size_t at=path.find(L'\\',3);at!=std::wstring::npos;at=path.find(L'\\',at+1)){
        const auto part=path.substr(0,at);
        if(!CreateDirectoryW(part.c_str(),nullptr)&&GetLastError()!=ERROR_ALREADY_EXISTS)return false;
    }
    return CreateDirectoryW(path.c_str(),nullptr)||GetLastError()==ERROR_ALREADY_EXISTS;
}
bool isFile(const std::wstring &path){const auto a=GetFileAttributesW(path.c_str());return a!=INVALID_FILE_ATTRIBUTES&&!(a&FILE_ATTRIBUTE_DIRECTORY);}
bool writeFile(const std::wstring &path,const char *data,uint64_t size){
    HANDLE f=CreateFileW(path.c_str(),GENERIC_WRITE,0,nullptr,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,nullptr);
    if(f==INVALID_HANDLE_VALUE)return false;
    bool ok=true;
    while(size>0&&ok){
        const DWORD chunk=size>(1u<<30)?(1u<<30):DWORD(size);DWORD wrote=0;
        ok=WriteFile(f,data,chunk,&wrote,nullptr)&&wrote==chunk;data+=chunk;size-=chunk;
    }
    CloseHandle(f);return ok;
}
void removeTree(const std::wstring &path){
    WIN32_FIND_DATAW d;HANDLE h=FindFirstFileW((path+L"\\*").c_str(),&d);
    if(h!=INVALID_HANDLE_VALUE){
        do{
            if(!wcscmp(d.cFileName,L".")||!wcscmp(d.cFileName,L".."))continue;
            const auto child=path+L"\\"+d.cFileName;
            if(d.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY)removeTree(child);else DeleteFileW(child.c_str());
        }while(FindNextFileW(h,&d));
        FindClose(h);
    }
    RemoveDirectoryW(path.c_str());
}
// Pack layout: "TLBBPACK1\n", 16 bytes version tag, u32 count, then per file u32 path length, utf-8 path, u64 size, bytes.
struct Reader{
    const char *at,*end;
    bool take(void *to,size_t n){if(size_t(end-at)<n)return false;std::memcpy(to,at,n);at+=n;return true;}
};
bool unpack(const std::wstring &target,const std::wstring &tag,Reader r){
    const auto temp=target+L".tmp"+std::to_wstring(GetCurrentProcessId());
    removeTree(temp);
    if(!makeDirs(temp))return false;
    uint32_t count=0;if(!r.take(&count,4)||count==0||count>256)return false;
    for(uint32_t i=0;i<count;++i){
        uint32_t len=0;uint64_t size=0;
        if(!r.take(&len,4)||len==0||len>260||size_t(r.end-r.at)<len)return false;
        auto name=widen(r.at,len);r.at+=len;
        if(!r.take(&size,8)||uint64_t(r.end-r.at)<size||name.find(L"..")!=std::wstring::npos||name.find(L':')!=std::wstring::npos)return false;
        for(auto &c:name)if(c==L'/')c=L'\\';
        const auto file=temp+L"\\"+name;const auto slash=file.rfind(L'\\');
        if(!makeDirs(file.substr(0,slash))||!writeFile(file,r.at,size))return false;
        r.at+=size;
    }
    if(!writeFile(temp+L"\\.complete",reinterpret_cast<const char*>(tag.data()),tag.size()*sizeof(wchar_t)))return false;
    if(MoveFileExW(temp.c_str(),target.c_str(),0))return true;
    // Another copy of the launcher may have finished first.
    const bool other=isFile(target+L"\\.complete");removeTree(temp);return other;
}
void dropOldVersions(const std::wstring &cache,const std::wstring &keep){
    WIN32_FIND_DATAW d;HANDLE h=FindFirstFileW((cache+L"\\runtime-*").c_str(),&d);
    if(h==INVALID_HANDLE_VALUE)return;
    do{
        if((d.dwFileAttributes&FILE_ATTRIBUTE_DIRECTORY)&&keep!=d.cFileName)removeTree(cache+L"\\"+d.cFileName); // In-use files stay; next start tries again.
    }while(FindNextFileW(h,&d));
    FindClose(h);
}
}

int WINAPI wWinMain(HINSTANCE,HINSTANCE,PWSTR,int){
    wchar_t self[MAX_PATH*4];const DWORD got=GetModuleFileNameW(nullptr,self,MAX_PATH*4);
    if(got==0||got>=MAX_PATH*4){fail(L"无法取得程序路径");return 1;}
    std::wstring base(self,got);base.resize(base.rfind(L'\\'));
    const auto packPath=base+L"\\TLBBRuntime.dll";
    HMODULE pack=LoadLibraryExW(packPath.c_str(),nullptr,LOAD_LIBRARY_AS_DATAFILE|LOAD_LIBRARY_AS_IMAGE_RESOURCE);
    if(!pack){fail(L"缺少 TLBBRuntime.dll，请重新安装");return 1;}
    HRSRC res=FindResourceW(pack,MAKEINTRESOURCEW(1),MAKEINTRESOURCEW(10));
    HGLOBAL loaded=res?LoadResource(pack,res):nullptr;
    const char *data=loaded?static_cast<const char*>(LockResource(loaded)):nullptr;
    const DWORD size=res?SizeofResource(pack,res):0;
    if(!data||size<30||std::memcmp(data,"TLBBPACK1\n",10)){fail(L"TLBBRuntime.dll 无效，请重新安装");return 1;}
    const auto tag=widen(data+10,16);
    const auto cache=base+L"\\data\\cache";
    const auto name=L"runtime-"+tag;
    const auto runtime=cache+L"\\"+name;
    if(!isFile(runtime+L"\\.complete")){
        if(!makeDirs(cache)||!unpack(runtime,tag,Reader{data+26,data+size})){fail(L"无法解压运行库到 data\\cache，请检查磁盘空间和目录权限");return 1;}
        dropOldVersions(cache,name);
    }
    FreeLibrary(pack);
    SetEnvironmentVariableW(L"TLBB_RUNTIME",runtime.c_str());
    SetDllDirectoryW(runtime.c_str());
    const auto appPath=runtime+L"\\TLBBApp.dll";
    HMODULE app=LoadLibraryExW(appPath.c_str(),nullptr,LOAD_WITH_ALTERED_SEARCH_PATH);
    if(!app){fail(L"无法加载 TLBBApp.dll（错误 "+std::to_wstring(GetLastError())+L"）。可以删除 data\\cache 后重试");return 1;}
    using Main=int (*)(int,char**);
    auto run=reinterpret_cast<Main>(reinterpret_cast<void*>(GetProcAddress(app,"TLBBAppMain")));
    if(!run){fail(L"TLBBApp.dll 缺少入口，请重新安装");return 1;}
    // Same arguments the app would get as its own executable.
    int argc=0;LPWSTR *wide=CommandLineToArgvW(GetCommandLineW(),&argc);
    std::vector<std::string> store;std::vector<char*> argv;
    for(int i=0;i<argc;++i){
        const int n=WideCharToMultiByte(CP_ACP,0,wide[i],-1,nullptr,0,nullptr,nullptr);
        std::string s(size_t(n>0?n:1),'\0');
        if(n>0)WideCharToMultiByte(CP_ACP,0,wide[i],-1,s.data(),n,nullptr,nullptr);
        store.push_back(std::move(s));
    }
    for(auto &s:store)argv.push_back(s.data());
    argv.push_back(nullptr);
    if(wide)LocalFree(wide);
    return run(argc,argv.data());
}
