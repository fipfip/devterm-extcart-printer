#ifndef CONFIG_H
#define CONFIG_H

// clang-format off
#include <freetype2/ft2build.h>
#include <freetype/freetype.h>
// clang-format on
/// raspberry pi CM3
#ifdef CM4
// make CFLAGS=-DCM4=1
#define BCM_GPIO_28 18
#define BCM_GPIO_29 19
#define BCM_GPIO_30 20
#define BCM_GPIO_31 21
#define BCM_GPIO_32 14
#define BCM_GPIO_33 15
#define BCM_GPIO_34 24
#define BCM_GPIO_35 25
#define BCM_GPIO_36 26
#define BCM_GPIO_37 27
#define BCM_GPIO_38 6
#define BCM_GPIO_39 7
#define BCM_GPIO_40 16
#define BCM_GPIO_41 17
#define BCM_GPIO_43 23
#else
#define BCM_GPIO_28 28
#define BCM_GPIO_29 29
#define BCM_GPIO_30 30
#define BCM_GPIO_31 31
#define BCM_GPIO_32 32
#define BCM_GPIO_33 33
#define BCM_GPIO_34 34
#define BCM_GPIO_35 35
#define BCM_GPIO_36 36
#define BCM_GPIO_37 37
#define BCM_GPIO_38 38
#define BCM_GPIO_39 39
#define BCM_GPIO_40 40
#define BCM_GPIO_41 41
#define BCM_GPIO_42 42
#define BCM_GPIO_43 43
#define BCM_GPIO_44 44
#define BCM_GPIO_45 45
#endif
// PA8-12 UART1
//#define SPI1_NSS_PIN PA4    //SPI_1 Chip Select pin is PA4. //no use in
//DevTerm

// ExtCart Definition
#define MCP23008_ADDR 0x20
#define MCP23008_PINBASE 100

#define ROUTE_EN BCM_GPIO_43
#define GPIO_X1 BCM_GPIO_37
#define GPIO_X2 BCM_GPIO_42

// maybe we should have names for these.. like, X1..X8 for internal, Y1..Y8 for external...
#define GPIO28 BCM_GPIO_28
#define GPIO29 BCM_GPIO_29
#define GPIO30 BCM_GPIO_30
#define GPIO31 BCM_GPIO_31
#define GPIO34 BCM_GPIO_34
#define GPIO35 BCM_GPIO_35

#define UART_TX BCM_GPIO_32
#define UART_RX BCM_GPIO_33

#define SPI_MOSI BCM_GPIO_38
#define SPI_SCL BCM_GPIO_39
#define SPI_CS BCM_GPIO_40
#define SPI_MISO BCM_GPIO_41

#define GPIO_Y0 (MCP23008_PINBASE+0)
#define GPIO_Y1 (MCP23008_PINBASE+1)
#define GPIO_Y2 (MCP23008_PINBASE+2)
#define GPIO_Y3 (MCP23008_PINBASE+3)
#define GPIO_Y4 (MCP23008_PINBASE+4)
#define GPIO_Y5 (MCP23008_PINBASE+5)
#define GPIO_Y6 (MCP23008_PINBASE+6)
#define GPIO_Y7 (MCP23008_PINBASE+7)

// printer definition
// original pin assignment commented out
// The following pins are incompatible and relocated:
// VH_PIN         [Not available, connected to SPI_CS anyway]
// PEM_PIN        [GPIO_Y7]
// THERMISTORPIN  [GPIO_Y6]
// STB1_PIN       [IO35]
// LATCH_PIN      [IO34]

#define VH_PIN BCM_GPIO_40 // ENABLE_VH required,PRT_EN

// #define LATCH_PIN BCM_GPIO_36 // 18
#define LATCH_PIN BCM_GPIO_34

//#define PEM_PIN BCM_GPIO_34   // 1 [PS,PAPER]
#define PEM_PIN GPIO_Y7

// DevTerm no VPS IO
//#define PEM_CTL_PIN
#define ENABLE_PEM
#define DISABLE_PEM

// https://www.raspberrypi.org/documentation/hardware/raspberrypi/spi/README.md
// enable SPI0 ALT0 in CM3 first
// in /boot/config.txt
// dtparam=spi=on
// dtoverlay=spi-gpio35-39
// then we can see GPIO38 GPIO39 in ALT0 Mode by `gpio readall`

#define MOSI_PIN BCM_GPIO_38
#define CLK_PIN BCM_GPIO_39

/**
 *@brief STB_NUMBER stand for STROBE NUMBER of lines, which means how many lines
 *        are going to be activated
 **/
#define STB_NUMBER 1

//#define STB1_PIN BCM_GPIO_37 // 13
#define STB1_PIN BCM_GPIO_35
#define STB2_PIN STB1_PIN
#define STB3_PIN STB1_PIN
#define STB4_PIN STB1_PIN
#define STB5_PIN STB1_PIN
#define STB6_PIN STB1_PIN

#define PH1_PIN BCM_GPIO_28
#define PH2_PIN BCM_GPIO_29
#define PH3_PIN BCM_GPIO_30
#define PH4_PIN BCM_GPIO_31

/// 0 1 3 2 mine
#define PA_PIN PH1_PIN  //
#define PNA_PIN PH2_PIN //
#define PB_PIN PH3_PIN  //
#define PNB_PIN PH4_PIN //

//#define THERMISTORPIN BCM_GPIO_35 // ADC,14
#define THERMISTORPIN GPIO_Y6

#define MOTOR_ENABLE1
#define MOTOR_ENABLE2

#define MOTOR_DISABLE1
#define MOTOR_DISABLE2

#define ENABLE_VH (void)0
#define READ_VH 0

#define LATCH_ENABLE pin_set(PIN_LATCH, 0)
#define LATCH_DISABLE pin_set(PIN_LATCH, 1)

#define ASK4PAPER pin_get(PIN_PEM)

#define ERROR_FEED_PITCH ((uint8_t)0x01)
#define IS_PAPER 0x00
#define NO_PAPER 0x01
#define HOT_PRINTER 0x02

#define FORWARD 0x01
#define BACKWARD 0x00

#define HOT 64

#define BCoefficent 3950
#define RthNominal 30000
#define TempNominal 25
#define ADCResolution 1024
#define SeriesResistor 30000
#define NumSamples 1

#define KELVIN 1
#define CELSIUS 0

#define ADC_FILE_PAT "/tmp/devterm_adc"

#define HEAT_TIME 100 // heat time + (0-f)*46

#define BAT_CAP "/sys/class/power_supply/axp20x-battery/capacity"
#define BAT_THRESHOLD 14 // %14 battery = low power

#define int16 uint16_t
#define int8 uint8_t

#define asciistart ((uint8_t)'A')
#define netxcharacter ((uint8_t)24)
#define Fontrows ((uint8_t)24)
#define FontColums ((uint8_t)16)

#define nextcharactercolum ((uint8_t)Fontrows / 8) // = 3

#define ASCII_TAB '\t' // Horizontal tab
#define ASCII_LF '\n'  // Line feed,10
#define ASCII_FF '\f'  // Form feed
#define ASCII_CR '\r'  // Carriage return
#define ASCII_EOT 4    // End of Transmission
#define ASCII_DLE 16   // Data Link Escape
#define ASCII_DC2 18   // Device control 2 //0x12
#define ASCII_ESC 27   // Escape //0x1b
#define ASCII_FS 28    // Field separator//0x1c
#define ASCII_GS 29    // Group separator //0x1d

#define PRINT_STATE 0
#define ESC_STATE 1
#define GET_IMAGE 2

#define ALIGN_LEFT 0
#define ALIGN_CENTER 1
#define ALIGN_RIGHT 2

#define IMAGE_MAX 9224

#define BITS8 8

#define MAX_DOTS 384
#define PRINTER_BITS MAX_DOTS
#define MAXPIXELS 48

#ifdef MTP03
#define MAX_DOTS 576
#define PRINTER_BITS MAX_DOTS
#define MAXPIXELS 72
#endif

#define FONT_MODE_0 0 // Internal
#define FONT_MODE_1 1 // External

// extract bits
#define LAST(k, n) ((k) & ((1 << (n)) - 1))
#define MID(k, m, n) LAST((k) >> (m), ((n) - (m)))

typedef struct _Margin {
  uint16_t width;
  uint8_t esgs;
} Margin;

typedef struct _FONT {

  uint8_t width; // in bits
  uint8_t height;
  uint8_t mode; // 0 internal pcf font array,1 external ttf font file
  const uint8_t *data;
  char *file;
} FONT;

typedef struct _ImageCache {

  uint16_t idx;
  uint16_t num;
  uint16_t width;
  uint16_t height;
  uint8_t need_print : 1;
  uint8_t revert_bits : 1;  // MSB OR LSB
  uint8_t cache[IMAGE_MAX]; // 48x192bytes(384x192 pixels) ,max

} ImageCache;

typedef struct _CONFIG {
  uint8_t state;
  uint8_t line_space;
  uint8_t align;
  uint8_t reverse; // reverse print
  uint8_t orient;
  uint8_t under_line;
  uint8_t feed_pitch;
  uint8_t density : 4; // 0-f,300+density*46 HEAT_TIME

  uint16_t wordgap : 10; // 1023 max
  uint8_t max_pts;       // max pts in print_dots_8bit_split
  uint8_t lock;
  int16_t degree; // char rotate 0,90,180,270, -90,-180,-270

  Margin margin;
  FONT *font;
  ImageCache *img;
  FILE *fp;

  FT_Face face;
  FT_Library ft;

  int (*printf)(struct _CONFIG *, char *, ...);

} CONFIG;

typedef struct _SerialCache {
  uint8_t idx;
  uint8_t utf8idx; // 0-4
  //  uint8_t data[77];//384/5, minium size font 5 pixel
  uint32_t data[MAX_DOTS]; // uint32_t for utf8 characters
} SerialCache;

typedef struct _TimeRec {
  unsigned int time;
  uint8_t last_status;
  uint8_t check;

} TimeRec;

void PrintDots8bit(uint8_t *Array, uint8_t characters, uint8_t feed_num);

uint8_t invert_bit(uint8_t a);

#endif
