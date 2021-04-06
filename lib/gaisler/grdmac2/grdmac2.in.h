#ifndef CONFIG_GRDMAC2_ENABLE
#define CONFIG_GRDMAC2_ENABLE 0
#endif

#ifndef CONFIG_GRDMAC2ACC
#define CONFIG_GRDMAC2ACC 0
#endif

#ifndef CONFIG_GRDMAC2FT
#define CONFIG_GRDMAC2FT 0
#endif

#if defined CONFIG_GRDMAC2DBITS32
#define CONFIG_GRDMAC2DBITS 32
#elif defined CONFIG_GRDMAC2DBITS64
#define CONFIG_GRDMAC2DBITS 64
#elif defined CONFIG_GRDMAC2DBITS128
#define CONFIG_GRDMAC2DBITS 128
#else
#define CONFIG_GRDMAC2DBITS 32
#endif

#if defined CONFIG_GRDMAC2ABITS0
#define CONFIG_GRDMAC2ABITS 0
#elif defined CONFIG_GRDMAC2ABITS1
#define CONFIG_GRDMAC2ABITS 1
#elif defined CONFIG_GRDMAC2ABITS2
#define CONFIG_GRDMAC2ABITS 2
#elif defined CONFIG_GRDMAC2ABITS3
#define CONFIG_GRDMAC2ABITS 3
#elif defined CONFIG_GRDMAC2ABITS4
#define CONFIG_GRDMAC2ABITS 4
#elif defined CONFIG_GRDMAC2ABITS5
#define CONFIG_GRDMAC2ABITS 5
#elif defined CONFIG_GRDMAC2ABITS6
#define CONFIG_GRDMAC2ABITS 6
#elif defined CONFIG_GRDMAC2ABITS7
#define CONFIG_GRDMAC2ABITS 7
#elif defined CONFIG_GRDMAC2ABITS8
#define CONFIG_GRDMAC2ABITS 8
#else
#define CONFIG_GRDMAC2ABITS 4
#endif
