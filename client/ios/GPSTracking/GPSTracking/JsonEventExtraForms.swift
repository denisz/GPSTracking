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
        "newAuto",
        "yearAuto",
        "colorAuto",
        "numberAuto",
        "VINAuto",
        "timeStealingFrom",
        "timeStealingTo",
        "comment"
    ],
    //разбой
    "2": [
        "age wrong",
        "height wrong",
        "body wrong",
        "nations",
        "special features",
        "auto"
    ],
    //хулиганство
    "4": [
        "age wrong",
        "height wrong",
        "body wrong",
        "nations",
        "special features",
        "auto"
    ],
    //скрылся с места  дтп
    "5" : [
        "victimWithTime",
        "culprit",
        "comment"
    ],
    //ребенок
    "6" : [
        "sex",
        "name baby",
        "age",
        "height",
        "body",
        "сolorhair",
        "coloreye",
        "special features",
        "when they saw",
        "which saw"
    ],
    //вещи
    "7": [
        "name",
        "where missing",
        "reward"
    ],
    //животные
    "10": [
        "who missing",
        "nickname",
        "where missing",
        "special features",
        "reward"
    ],
    //взять на буксир
    "8" : [
        "destination",
        "newAuto",
        "cable",
        "numberAuto",        
        "comment"
    ],
    
    //1 литр
    "9" : [
        "fuel"
    ],

    //автостоп
    "11" : [
        "destination",
        "how many people",
        "price",
        "comment"
    ],
    
    
    //очевидец анкеты

    //угон
    "12":[
        "newAuto",
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
        "nation",
        "special features",
        "auto"
    ],
    //скрылся с места  дтп c временим очевидец
    "14" : [
        "victimWithTime",
        "culprit",
        "comment"
    ],
    //Хулиганство
    "18":[
        "age wrong",
        "height wrong",
        "body wrong",
        "nation",
        "special features",
        "auto"
    ],
    //Скрылся с места не очевидец
    "16" : [
        "victimWithFromTo",
        "culprit with know",
        "comment"
    ],

    //Похищение
    "17":[
        "hijack",
        "reaver"
    ],
    
    //дополнительно
    //боюсь идти одна
    "19" : [
        "destination",
        "with man",
        "can wait",
        "comment"
    ],
    //я тебя жду
    "20" : [
        "contacts",
        "stage",
        "comment"
    ],
    
    //преступление
    "21" : [
        "count reaver",
        "age wrong",
        "height wrong",
        "body wrong",
        "nations",
        "special features",
        "auto",
        "multi items"
    ],
    //Похищение человека
    "22": [
        "hijack",
        "reaver",
        "multi items"
    ]
]