#ifdef HX_WINDOWS
#include "setup_hx_windows.h"
#elif defined(HXCPP_RPI)
#include "setup_hx_rpi.h"
#else
#error "Unknown platform"
#endif
