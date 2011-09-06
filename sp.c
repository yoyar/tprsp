
#ifndef SP_C_INCLUDED
#define SP_C_INCLUDED

#include <jansson.h>

char wordbuf[1024];

json_t * json;
json_t * itemlist;

// #define NDEBUG 1;

#ifdef NDEBUG
#define Dprintf(FORMAT, ...) ((void)0)
#define Dputs(MSG) ((void)0)
#else
#define Dprintf(FORMAT, ...) fprintf(stderr, "%s, line %i: " FORMAT "\n",  __FILE__, __LINE__, __VA_ARGS__)
#define Dputs(MSG) Dprintf("%s", MSG)
#endif

#endif

