#include "hal_gpio.h"

#include <errno.h>
#include <gpiod.h>

typedef struct
{
    unsigned chipno;
    struct gpiod_chip *p_chip;
    struct gpiod_line *p_line;
    bool inuse;
} pindesc_t;

static pindesc_t s_pins[PIN_MAX] = {
	{.chipno = -1, .p_chip = NULL, .p_line = NULL, .inuse = false},
	{.chipno = -1, .p_chip = NULL, .p_line = NULL, .inuse = false},
	{.chipno = -1, .p_chip = NULL, .p_line = NULL, .inuse = false},
	{.chipno = -1, .p_chip = NULL, .p_line = NULL, .inuse = false},
	{.chipno = -1, .p_chip = NULL, .p_line = NULL, .inuse = false},
	{.chipno = -1, .p_chip = NULL, .p_line = NULL, .inuse = false},
	{.chipno = -1, .p_chip = NULL, .p_line = NULL, .inuse = false}
};

static const char *pin_to_str(namedpins_t pin);

int pin_map(const namedpins_t pin, const pincfg_t config)
{
	 // Try to reuse handles if they are already allocated
    for (int i = 0; i < PIN_MAX; ++i)
    {
        // Ignore its own index
        if (pin == i)
            continue;

        // This index has its chip initialized already,
        // try to reuse it if the chip number matches
        if (s_pins[i].p_chip && (s_pins[i].chipno == config.chip))
        {
            // Reuse the handle
            s_pins[pin].p_chip = s_pins[i].p_chip;
            s_pins[pin].chipno = config.chip;
        }
    }

    if (s_pins[pin].chipno == -1)
    {
        // No preexisting allocation for the chip found - make it
        s_pins[pin].p_chip = gpiod_chip_open_by_number(config.chip);
        if (!s_pins[pin].p_chip)
        {
            //LOG_ERR("Could not allocate gpiochip%d", p_pincfg->chip);
            return -EINVAL;
        }
        else
        {
            s_pins[pin].chipno = config.chip;
        }
    }

    // At this point we got the chip, the line is unique for each pin
    s_pins[pin].p_line = gpiod_chip_get_line(s_pins[pin].p_chip, config.line);
    if (!s_pins[pin].p_line)
    {
        //LOG_ERR("Could not allocate line %d for gpiochip%d", p_pincfg->line, p_pincfg->chip);
        return -EINVAL;
    }

    return 0;
}

int pin_config_input(const namedpins_t pin)
{
	return gpiod_line_request_input(s_pins[pin].p_line, pin_to_str(pin));
}

int pin_config_output(const namedpins_t pin, const int default_val)
{
	return gpiod_line_request_output(s_pins[pin].p_line, pin_to_str(pin), default_val);
}

int pin_get(const namedpins_t pin)
{
    return gpiod_line_get_value(s_pins[pin].p_line);
}
void pin_set(const namedpins_t pin, const int val)
{
	struct timespec ts = { 1, 0 };
    gpiod_line_set_value(s_pins[pin].p_line, val);
    (void)gpiod_line_event_wait(s_pins[pin].p_line, &ts);
}

static const char *pin_to_str(namedpins_t pin)
{
    const char *p_name = "undefined";
    switch (pin)
    {
		case PIN_LATCH:
			p_name = "printer.latch";
			break;
		case PIN_PEM:
			p_name = "printer.pem";
			break;
		case PIN_STB:
			p_name = "printer.stb";
			break;
		case PIN_PA:
			p_name = "printer.pa";
			break;
		case PIN_PNA:
			p_name = "printer.pna";
			break;
		case PIN_PB:
			p_name = "printer.pb";
			break;
		case PIN_PNB:
			p_name = "printer.pnb";
			break;
		default:
			break;
    }

    return p_name;
}
