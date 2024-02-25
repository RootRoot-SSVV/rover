#include "demo_module.h"

#define PWM_MAX_LEVEL 255


// component    gpio
// led1         3
// led2         4
// led3         5
// rgb          0, 1, 2
// buzzer       7

void init_demo_module(){
    // Buzzer
    gpio_set_dir(7, GPIO_OUT);

    // LED 1-3
    gpio_set_dir(3, GPIO_OUT);
    gpio_set_dir(4, GPIO_OUT);
    gpio_set_dir(5, GPIO_OUT);

    // LED RGB
    init_pwm(0);
    init_pwm(1);
    init_pwm(2);
}

void demo_module_reaction() {
    // [mode][id][motor][led1][led2][led3][R][G][B][BUZZER]
    //    0    1    2      3    4     5    6  7  8    9

    uint8_t *message = get_input_buffer();

    gpio_put(3, message[2]);
    gpio_put(4, message[3]);
    gpio_put(5, message[4]);
    
    gpio_put(7, message[8]);

    uint8_t R = message[5];
    uint8_t G = message[6];
    uint8_t B = message[7];
    
    set_pwm(0, R / 255.0);
    set_pwm(1, G / 255.0);
    set_pwm(2, B / 255.0);
}

// Inicijalizacija PWM-a
void init_pwm(uint8_t gpio) {
    uint slice_num = pwm_gpio_to_slice_num(gpio);
    pwm_config config = pwm_get_default_config();

    pwm_config_set_wrap(&config, PWM_MAX_LEVEL);
    pwm_init(slice_num, &config, true);
    gpio_set_function(gpio, GPIO_FUNC_PWM);
}

// Postavi PWM
void set_pwm(uint8_t gpio, float duty_cycle) {
    uint slice_num = pwm_gpio_to_slice_num(gpio);
    uint pwm_level = (uint)(duty_cycle * PWM_MAX_LEVEL);
    pwm_set_gpio_level(gpio, pwm_level);
}
