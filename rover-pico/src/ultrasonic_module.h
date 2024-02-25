#ifndef ULTRASONIC_MODULE_H_
#define ULTRASONIC_MODULE_H_

#define TRIG 1
#define ECHO 0

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"
#include "hardware/timer.h"
#include "bluetooth.h"

void init_ultrasonic_module();
int get_distance();
void ultrasonic_module_reaction();

#endif // ULTRASONIC_MODULE_H_