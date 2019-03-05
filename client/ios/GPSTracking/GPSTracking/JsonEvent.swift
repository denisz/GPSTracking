//
//  JsonEvent.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/10/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
typealias EventParams = [[String: AnyObject]]

let EventInArchive = ["3", "1", "7", "2"] as [String];

let EventContext: EventParams = [
    [
        "title"         : "Угроза физического воздействия со стороны третьих лиц",
        "help"          : "Цель запроса - просьба к пользователям присутствовать рядом до приезда полиции Пользователь, принявший данный сигнал, находит подавшего запрос и находится  рядом до приезда полиции, либо разрешения ситуации.",
        "value"         : "7",
        "submit"        : true
    ],
    [
        "title"         : "Преступное посягательство",
        "help"          : "",
        "value"         : "3",
        "subtype"       : ["1", "2", "4", "5"] as [String]
    ],
    [
        "title"         : "Пропажа",
        "help"          : "",
        "value"         : "2",
        "subtype"       : ["6","7","10"] as [String]
    ],
    [
        "title"         : "Запрос о помощи на дороге",
        "help"          : "",
        "value"         : "4",
        "subtype"       : ["8", "9", "11"] as [String]
    ],
    [
        "title"     : "Пойдем вместе",
        "help"      : "Цель запроса - найти попутчика . чтобы пройти по безлюдному участку маршрута.",
        "submit"    : true,
        "extra"         : true,
        "access": true,
        "extraFields"   : "19",
        "value"     : "5"
    ],
    [
        "title"         : "Я тебя жду",
        "help"          : "Цель запроса - показать  знакомому пользователю  где именно и кто  его ожидает.",
        "value"      : "6",
        "extra" : true,
        "access": true,
        "extraFields" : "20",
        "submit"    : true
    ],
    [
        "title"         : "Очевидец",
        "help"          : "Цель сообщения - формирование базы свидетельских показаний . Сообщение должно быть отправлено с места происшествия и в соответствии с регламентом кризисных ситуаций.",
        "value"         : "1",
        "subtype"       : ["13", "16", "17", "18"] as [String]
    ]
]

let EventSubtypes: EventParams = [
    
    [
        "title" : "Угон",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску авто. Усиление бдительности граждан.",
        "attach": true,
        "extra" : true,
        "access"        : true,
        "extraFields" : "1",
        "submit": true,
        "value" : "1"
    ],
    [
        "title" : "Разбой",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску преступников. Усиление бдительности граждан.",
        "attach": true,
        "submit": true,
        "access": true,
        "extra" : true,
        "extraFields" : "21",
        "value" : "2"
    ],
    [
        "title" : "Хулиганство",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску преступников. Усиление бдительности граждан.",
        "attach": true,
        "submit": true,
        "access": true,
        "extra" : true,
        "extraFields" : "21",
        "value" : "4"
    ],
    [
        "title" : "Скрылся с места ДТП",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску правонарушителя, сбор свидетельских показаний. Усиление бдительности граждан.",
        "submit": true,
        "access": true,
        "attach": true,
        "extra" : true,
        "extraFields" : "16",
        "value" : "5"
    ],
    [
        "title" : "Ребенок",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску ребенка, сбор свидетельских показаний. Усиление бдительности граждан",
        "submit": true,
        "access": true,
        "attach": true,
        "extra" : true,
        "extraFields" : "6",
        "value" : "6"
    ],
    [
        "title" : "Вещи",
        "help"  : "Цель запроса - просьба откликнуться нашедшего, либо всех кто видел. В комментарии можно указать сумму вознаграждения.",
        "submit": true,
        "access": true,
        "attach": true,
        "extra" : true,
        "extraFields" : "7",
        "value" : "7"
    ],
    [
        "title" : "Животное",
        "help"  : "Цель запроса - просьба откликнуться нашедшего, либо всех кто видел. В комментарии можно указать сумму вознаграждения.",
        "submit": true,
        "access": true,
        "attach": true,
        "extra" : true,
        "extraFields" : "10",
        "value" : "10"
    ],
    [
        "title" : "Взять на буксир",
        "help"  : "Цель запроса - просьба отбуксировать ТС, до ближайшего населенного пункта либо сервиса.",
        "submit": true,
        "access": true,
        "extra" : true,
        "extraFields" : "8",
        "value" : "8"
    ],
    [
        "title" : "1 литр",
        "help"  : "Цель запроса - просьба поделиться горючим, с указанием ТС. Запрос не принимается в городской черте.",
        "submit": true,
        "access": true,
        "extra" : true,
        "extraFields" : "9",
        "value" : "9"
    ],
    [
        "title" : "Автостоп",
        "help"  : "Цель запроса - просьба подвезти, с указанием населенного пункта либо места. Запрос не принимается в городской черте.",
        "submit": true,
        "access": true,
        "extra" : true,
        "extraFields" : "11",
        "value" : "11"
    ],
    
    //очевидец
    [
        "title" : "Разбой",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску преступников. Усиление бдительности граждан.",
        "submit": true,
        "access": true,
        "attach": true,
        "extra" : true,
        "extraFields" : "21",
        "value" : "13"
    ],
    [
        "title" : "Скрылся с места ДТП",
        "help"  : "",
        "submit": true,
        "access": true,
        "attach": true,
        "extra" : true,
        "extraFields" : "14",
        "value" : "16"
    ],
    [
        "title" : "Похищение человека",
        "help"  : "",
        "attach": true,
        "access": true,
        "submit": true,
        "extra" : true,
        "extraFields" : "22",
        "value" : "17"
    ],
    [
        "title" : "Хулиганство",
        "help"  : "",
        "submit": true,
        "attach": true,
        "access": true,
        "extra" : true,
        "extraFields" : "21",
        "value" : "18"
    ]
]