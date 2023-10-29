#pragma once

typedef enum
{
	PIN_LATCH = 0,
	PIN_PEM,
	PIN_STB,
	PIN_PA,
	PIN_PNA,
	PIN_PB,
	PIN_PNB,
	PIN_MAX
} namedpins_t;

typedef struct
{
    int chip;
    int line;
} pincfg_t;

int pin_map(const namedpins_t pin, const pincfg_t config);
int pin_config_input(const namedpins_t pin);
int pin_config_output(const namedpins_t pin, const int default_val);
int pin_get(const namedpins_t pin);
void pin_set(const namedpins_t pin, const int val);
