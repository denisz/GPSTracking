//
//  JsonEventExtraForms.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/16/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation

typealias EventExtraParams = [String: [String]]

let EventExtra: EventExtraParams = [
    //угон
    "1" : [
        "markAuto",
        "modelAuto",
        "bodyAuto",
        "yearAuto",
        "colorAuto",
        "numberAuto",
        "timeStealingFrom",
        "timeStealingTo"
    ],
    //разбой
    "2": [
        "age wrong",
        "height wrong",
        "body wrong",
        "nations",
        "special features"
    ],
    //хулиганство
    "4": [
        "age wrong",
        "height wrong",
        "body wrong",
        "nations",
        "special features"
    ],
    //скрылся с места  дтп
    "5" : [
        "victim",
        "culprit"
    ],
    //ребенок
    "6" : [
        "sex",
        "age",
        "height",
        "body",
        "сolorhair",
        "coloreye",
        "when they saw",
        "which saw",
        "special features",
        "phone"
    ],
    //вещи
    "7": [
        "name",
        "where missing",
        "reward",
        "telephone"
    ],
    //взять на буксир
    "8" : [
        "markAuto",
        "modelAuto",
        "bodyAuto",
        "cable",
        "numberAuto",
        "destination"
    ],
    //автостоп
    "11" : [
        "how many people",
        "price",
        "destination"
    ],
    //очевидец анкеты

    //угон
    "12":[
        "markAuto",
        "modelAuto",
        "bodyAuto",
        "yearAuto",
        "colorAuto",
        "numberAuto",
        "timeStealingFrom",
        "timeStealingTo"
    ],
    //Правонарушение
    "13":[
        "age wrong",
        "height wrong",
        "body wrong",
        "nations",
        "special features"
    ],
    "18":[
        "age wrong",
        "height wrong",
        "body wrong",
        "nations",
        "special features"
    ],
    //Пропажа ребенка
    "14":[
        "sex",
        "age",
        "height",
        "body",
        "сolorhair",
        "coloreye",
        "special features"
    ],
    //Пропажа вещи
    "15":[
        "name"
    ],
    //Скрылся с места
    "16":[
        "markAuto",
        "modelAuto",
        "bodyAuto",
        "yearAuto",
        "colorAuto",
        "numberAuto",
        "timeAccident"
    ],
    //Похищение
    "17":[
        
    ],
    "9" : [
        "fuel"
    ]
]