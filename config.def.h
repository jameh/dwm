/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int gappx     = 5;        /* gaps between windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;     /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "monospace:size=10" };
static const char dmenufont[]       = "monospace:size=10";
static char normbgcolor[]           = "#222222";
static char normbordercolor[]       = "#444444";
static char normfgcolor[]           = "#bbbbbb";
static char selfgcolor[]            = "#eeeeee";
static char selbordercolor[]        = "#005577";
static char selbgcolor[]            = "#005577";
static char *colors[][3] = {
       /*               fg           bg           border   */
       [SchemeNorm] = { normfgcolor, normbgcolor, normbordercolor },
       [SchemeSel]  = { selfgcolor,  selbgcolor,  selbordercolor  },
};

/* tagging */
static const char *tags[] = { "1:dev", "2:web", "3:media", "4:music", "5:org", "6", "7", "8", "9" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class             instance    title              tags mask     isfloating   monitor */
	{ "Gimp",            NULL,       NULL,              0,            1,           -1 },
	{ "Firefox",         NULL,       NULL,              1 << 1,       0,           -1 },
	{ "Chromium",        NULL,       NULL,              1 << 1,       0,           -1 },
	{ "Spotify",         NULL,       NULL,              1 << 3,       0,           -1 },
	{ "Show-splash-gtk", NULL,       NULL,              1 << 3,       0,           -1 },
	{ "Bitwig Studio",   NULL,       NULL,              1 << 3,       0,           -1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 1;    /* 1 means respect size hints in tiled resizals */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
	{ "|M|",      centeredmaster },
	{ ">M>",      centeredfloatingmaster },
};

/* key definitions */
#define MODKEY Mod3Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", normbgcolor, "-nf", normfgcolor, "-sb", selbordercolor, "-sf", selfgcolor, NULL };
static const char *termcmd[]  = { "st", NULL };
static const char scratchpadname[] = "scratchpad";
static const char *scratchpadcmd[] = { "st", "-t", scratchpadname, "-g", "120x34", NULL };

static Key keys[] = {
	/* modifier                     key        function        argument */
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

/* signal definitions */
/* trigger signals using `xsetroot -name "fsignal:<signame>"` */
static Signal signals[] = {
	// alphabetical by function
	/* signum             function        argument  */
	{ "focusmon-next",    focusmon,       {.i = +1 } },
	{ "focusmon-prev",    focusmon,       {.i = -1 } },
	{ "focusstack-next",  focusstack,     {.i = +1 } },
	{ "focusstack-prev",  focusstack,     {.i = -1 } },
	{ "nmaster-inc",      incnmaster,     {.i = +1 } },
	{ "nmaster-dec",      incnmaster,     {.i = -1 } },
	{ "rotate-up",        inplacerotate,  {.i = +1} },
	{ "rotate-down",      inplacerotate,  {.i = -1} },
	{ "killclient",       killclient,     {0} },
	{ "quit",             quit,           {0} },
	{ "setgaps-inc",      setgaps,        {.i = -1 } },
	{ "setgaps-default",  setgaps,        {.i = +1 } },
	{ "setgaps-dec",      setgaps,        {.i = 0  } },
	{ "layout-tile",      setlayout,      {.v = &layouts[0]} },
	{ "layout-float",     setlayout,      {.v = &layouts[1]} },
	{ "layout-monocle",   setlayout,      {.v = &layouts[2]} },
	{ "layout-cmaster",   setlayout,      {.v = &layouts[3]} },
	{ "layout-cfmaster",  setlayout,      {.v = &layouts[4]} },
	{ "mfact-inc",        setmfact,       {.f = +0.05} },
	{ "mfact-dec",        setmfact,       {.f = -0.05} },
	{ "dmenu",            spawn,          {.v = dmenucmd } },
	{ "term",             spawn,          {.v = termcmd } },
	{ "tagmon-inc",       tagmon,         {.i = +1 } },
	{ "tagmon-dec",       tagmon,         {.i = -1 } },
	{ "focusmon-inc",     focusmon,       {.i = -1 } },
	{ "focusmon-dec",     focusmon,       {.i = +1 } },
	{ "togglebar",        togglebar,      {0} },
	{ "togglefloat",      togglefloating, {0} },
	{ "togglescratch",    togglescratch,  {.v = scratchpadcmd } },
	{ "view",             view,           {0} },
	{ "xrdb",             xrdb,           {.v = NULL } },
	{ "zoom",             zoom,           {0} },
};
