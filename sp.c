
char wordbuf[1024];

char linebuf[1024];

// #define NDEBUG 0;

#ifdef NDEBUG
#define Dprintf(FORMAT, ...) ((void)0)
#define Dputs(MSG) ((void)0)
#else
//#define Dprintf(FORMAT, ...) fprintf(stderr, "%s() in %s, line %i: " FORMAT "\n", __func__, __FILE__, __LINE__, __VA_ARGS__)
#define Dprintf(FORMAT, ...) fprintf(stdout, "%s, line %i: " FORMAT "\n",  __FILE__, __LINE__, __VA_ARGS__)
#define Dputs(MSG) Dprintf("%s", MSG)
#endif


