#ifndef SYSTEM_MANAGER_H_
#define SYSTEM_MANAGER_H_

#include <stdlib.h>
#include "pico/stdlib.h"
#include "hardware/gpio.h"

void system_manager_init();

void bus_init();

void scan_for_modules();

void set_module_id(uint8_t id);
void module_setup(int id);

uint8_t* get_connected_modules();
uint8_t get_number_of_modules();


// TODO:
void motor_init();
void motor_driver(uint8_t motorInt);

#endif // SYSTEM_MANAGER_H_