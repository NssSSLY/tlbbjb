#include <windows.h>
#include <string>
// Owned test-only windows; never installed as part of the client.
static bool launcher=false,started=false;static std::wstring root;
static bool spawn(const std::wstring &program){std::wstring command=L"\""+program+L"\"";STARTUPINFOW si{};si.cb=sizeof(si);PROCESS_INFORMATION pi{};if(!CreateProcessW(program.c_str(),command.data(),nullptr,nullptr,FALSE,0,nullptr,root.c_str(),&si,&pi))return false;CloseHandle(pi.hThread);CloseHandle(pi.hProcess);return true;}
static LRESULT CALLBACK procedure(HWND w,UINT msg,WPARAM a,LPARAM b){if(msg==WM_COMMAND&&LOWORD(a)==1001&&launcher&&!started){started=true;if(spawn(root+L"\\Bin64\\Game.exe"))DestroyWindow(w);return 0;}if(msg==WM_DESTROY){PostQuitMessage(0);return 0;}if(msg==WM_TIMER){DestroyWindow(w);return 0;}return DefWindowProcW(w,msg,a,b);}
int WINAPI WinMain(HINSTANCE instance,HINSTANCE,LPSTR,int){
    wchar_t path[32768]{};GetModuleFileNameW(nullptr,path,32768);std::wstring file(path);auto slash=file.find_last_of(L"\\/");auto name=file.substr(slash+1);auto dir=file.substr(0,slash);
    root=dir;
    if(name==L"Launch.exe"){if(!spawn(root+L"\\Launch.bin"))return 2;Sleep(650);return 0;}
    launcher=name==L"Launch.bin";
    WNDCLASSW cls{};cls.lpfnWndProc=procedure;cls.hInstance=instance;cls.lpszClassName=L"TLBBClientOwnedFixture";cls.hbrBackground=HBRUSH(COLOR_WINDOW+1);RegisterClassW(&cls);
    HWND window=CreateWindowW(cls.lpszClassName,launcher?L"TLBB launcher fixture (not a game)":L"TLBB binding fixture (not a game)",WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,CW_USEDEFAULT,1000,720,nullptr,nullptr,instance,nullptr);if(launcher)CreateWindowW(L"Button",L"开始游戏",WS_CHILD|WS_VISIBLE|BS_PUSHBUTTON,30,40,140,40,window,HMENU(1001),instance,nullptr);ShowWindow(window,SW_SHOW);SetTimer(window,1,90000,nullptr);MSG msg{};while(GetMessageW(&msg,nullptr,0,0)>0){TranslateMessage(&msg);DispatchMessageW(&msg);}return 0;
}
