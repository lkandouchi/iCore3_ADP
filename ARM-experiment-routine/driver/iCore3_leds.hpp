
/**
 * @file iCore3_leds.hpp
 * @brief Header file for the iCore3_leds class.
 *
 * This file contains the declaration of the iCore3_leds class, which provides
 * functionality to control LEDs on the iCore3 development board.
 */
#pragma once

#include "..\fwlib\inc\stm32f4xx_gpio.h"
#include "..\fwlib\inc\stm32f4xx_rcc.h"

/**
 * @class iCore3_leds
 * @brief Class for controlling LEDs on the iCore3 development board.
 *
 * The iCore3_leds class provides methods to initialize and control the LEDs on
 * the iCore3 development board. It uses the STM32F4xx GPIO and RCC libraries
 * for GPIO configuration and control.
 */
class iCore3_leds {
    private:
    /* data */
    public:
    /**
     * @brief Constructor for the iCore3_leds class.
     */
    iCore3_leds(/* args */) {
    }

    /**
     * @brief Destructor for the iCore3_leds class.
     */
    ~iCore3_leds() {
    }

    /**
     * @brief Initializes the GPIO pins for the LEDs.
     * @return 0 if successful, otherwise an error code.
     */
    int initialize(void) {
        GPIO_InitTypeDef GPIO_uInitStructure;
        RCC_AHB1PeriphClockCmd(RCC_AHB1Periph_GPIOI, ENABLE);
        GPIO_uInitStructure.GPIO_Pin = GPIO_Pin_5 | GPIO_Pin_6 | GPIO_Pin_7;
        GPIO_uInitStructure.GPIO_PuPd = GPIO_PuPd_UP;
        GPIO_uInitStructure.GPIO_Speed = GPIO_Speed_100MHz;

        GPIO_Init(GPIOI, &GPIO_uInitStructure);
        GPIO_SetBits(GPIOI, GPIO_Pin_5 | GPIO_Pin_6 | GPIO_Pin_7);

        return 0;
    }

    /**
     * @brief Turns off the red LED.
     */
    void RED_OFF() {
        GPIO_SetBits(GPIOI, GPIO_Pin_5);
    }

    /**
     * @brief Turns on the red LED.
     */
    void RED_ON() {
        GPIO_ResetBits(GPIOI, GPIO_Pin_5);
    }

    /**
     * @brief Turns off the green LED.
     */
    void GREEN_OFF() {
        GPIO_SetBits(GPIOI, GPIO_Pin_6);
    }

    /**
     * @brief Turns on the green LED.
     */
    void GREEN_ON() {
        GPIO_ResetBits(GPIOI, GPIO_Pin_6);
    }

    /**
     * @brief Turns off the blue LED.
     */
    void BLUE_OFF() {
        GPIO_SetBits(GPIOI, GPIO_Pin_7);
    }

    /**
     * @brief Turns on the blue LED.
     */
    void BLUE_ON() {
        GPIO_ResetBits(GPIOI, GPIO_Pin_7);
    }
};
