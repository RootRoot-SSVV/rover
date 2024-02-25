#ifndef DEMO_MODULE_H_
#define DEMO_MODULE_H_

#include <stdlib.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "hardware/pwm.h"
#include "bluetooth.h"

void init_demo_module();
void demo_module_reaction();
void init_pwm(uint8_t gpio);
void set_pwm(uint8_t gpio, float duty_cycle);

#endif // DEMO_MODULE_H_