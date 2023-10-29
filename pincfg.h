#pragma once

#include "hal_gpio.h"

// clang-format off
#define PIN_NONE     { .chip = -1, .line = -1 }

#ifdef CM4
#  error "Pin configuration not set for CM4"
#else

#define PIN_IO28     (pincfg_t){ .chip =  3, .line = 16  }
#define PIN_IO29     (pincfg_t){ .chip =  3, .line = 17  }
#define PIN_IO30     (pincfg_t){ .chip =  3, .line = 13  }
#define PIN_IO31     (pincfg_t){ .chip =  4, .line = 29  }
//#define PIN_IO32     (pincfg_t){ .chip =  ?, .line = ?  }
//#define PIN_IO33     (pincfg_t){ .chip =  ?, .line = ?  }
#define PIN_IO34     (pincfg_t){ .chip =  3, .line = 4  }
#define PIN_IO35     (pincfg_t){ .chip =  3, .line = 5  }
//#define PIN_IO36     (pincfg_t){ .chip =  ?, .line = ?  }
//#define PIN_IO37     (pincfg_t){ .chip =  ?, .line = ?  }
//#define PIN_IO38     (pincfg_t){ .chip =  ?, .line = ?  }
//#define PIN_IO39     (pincfg_t){ .chip =  ?, .line = ?  }
//#define PIN_IO40     (pincfg_t){ .chip =  ?, .line = ?  }
//#define PIN_IO41     (pincfg_t){ .chip =  ?, .line = ?  }
//#define PIN_IO42     (pincfg_t){ .chip =  ?, .line = ?  }
//#define PIN_IO43     (pincfg_t){ .chip =  ?, .line = ?  }
//#define PIN_IO44     (pincfg_t){ .chip =  ?, .line = ?  }
//#define PIN_IO45     (pincfg_t){ .chip =  ?, .line = ?  }

/*
#define PIN_IO28     (pincfg_t){ .chip =  3, .line = 0  }
#define PIN_IO29     (pincfg_t){ .chip =  3, .line = 1  }
#define PIN_IO30     (pincfg_t){ .chip =  3, .line = 2  }
#define PIN_IO31     (pincfg_t){ .chip =  3, .line = 3  }
#define PIN_IO32     (pincfg_t){ .chip =  3, .line = 4  }
#define PIN_IO33     (pincfg_t){ .chip =  3, .line = 5  }
#define PIN_IO34     (pincfg_t){ .chip =  3, .line = 6  }
#define PIN_IO35     (pincfg_t){ .chip =  3, .line = 7  }
#define PIN_IO36     (pincfg_t){ .chip =  3, .line = 8  }
#define PIN_IO37     (pincfg_t){ .chip =  3, .line = 9  }
#define PIN_IO38     (pincfg_t){ .chip =  3, .line = 10 }
#define PIN_IO39     (pincfg_t){ .chip =  3, .line = 11 }
#define PIN_IO40     (pincfg_t){ .chip =  3, .line = 12 }
#define PIN_IO41     (pincfg_t){ .chip =  3, .line = 13 }
#define PIN_IO42     (pincfg_t){ .chip =  3, .line = 14 }
#define PIN_IO43     (pincfg_t){ .chip =  3, .line = 15 }
#define PIN_IO44     (pincfg_t){ .chip =  3, .line = 16 }
#define PIN_IO45     (pincfg_t){ .chip =  3, .line = 17 }
*/

#endif

#define PIN_YIO0  (pincfg_t){ .chip =  6, .line = 0 }
#define PIN_YIO1  (pincfg_t){ .chip =  6, .line = 1 }
#define PIN_YIO2  (pincfg_t){ .chip =  6, .line = 2 }
#define PIN_YIO3  (pincfg_t){ .chip =  6, .line = 3 }
#define PIN_YIO4  (pincfg_t){ .chip =  6, .line = 4 }
#define PIN_YIO5  (pincfg_t){ .chip =  6, .line = 5 }
#define PIN_YIO6  (pincfg_t){ .chip =  6, .line = 6 }
#define PIN_YIO7  (pincfg_t){ .chip =  6, .line = 7 }

// clang-format on
