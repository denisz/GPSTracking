//
//  JsonEvent.swift
//  GPSTrakcing
//
//  Created by denis zaytcev on 5/10/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
typealias EventParams = [[String: AnyObject]]

let EventContext: EventParams = [
    [
        "title"         : "Очевидец",
        "help"          : "Цель сообщения - формирование базы свидетельских показаний . Сообщение должно быть отправлено с места происшествия и в соответствии с регламентом кризисных ситуаций.",
        "value"         : "1",
        "subtype"       : ["12", "13", "14", "15", "16", "17", "18"]
    ],
    [
        "title"         : "Пропажа",
        "help"          : "",
        "value"         : "2",
        "subtype"       : ["6","7"]
    ],
    [
        "title"         : "Преступное посягательство",
        "help"          : "",
        "value"         : "3",
        "subtype"       : ["1", "2", "4", "5"]
    ],
    [
        "title"         : "Запрос о помощи на дороге",
        "help"          : "",
        "value"         : "4",
        "subtype"       : ["8", "9", "11"]
    ],
    [
        "title"         : "Боюсь идти одна или, пойдем вместе",
        "help"          : "Цель запроса - найти попутчика . чтобы пройти по безлюдному участку маршрута.",
        "value"         : "5"
    ],
    [
        "title"         : "Найди меня или, я тебя жду",
        "help"          : "Цель запроса - показать  знакомому пользователю  где именно и кто  его ожидает.",
        "value"         : "6"
    ],
    [
        "title"         : "Угроза физического воздействия со стороны третьих лиц",
        "help"          : "Цель запроса - просьба к пользователям присутствовать рядом до приезда полиции Пользователь, принявший данный сигнал, находит подавшего запрос и находится  рядом до приезда полиции, либо разрешения ситуации.",
        "value"         : "7",
        "submit"        : true
    ]
]

let EventSubtypes: EventParams = [
    [
        "title" : "Угон",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску авто. Усиление бдительности граждан.",
        "attach": true,
        "submit": true,
        "value" : "1"
    ],
    [
        "title" : "Разбой",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску преступников. Усиление бдительности граждан.",
        "form" : "MultiFormViewController",
        "multi" : true,
        "attach": true,
        "submit": true,
        "value" : "2"
    ],
    [
        "title" : "Хулиганство",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску преступников. Усиление бдительности граждан.",
        "form" : "MultiFormViewController",
        "multi" : true,
        "attach": true,
        "submit": true,
        "value" : "4"
    ],
    [
        "title" : "Скрылся с места ДДП",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску правонарушителя, сбор свидетельских показаний. Усиление бдительности граждан.",
        //"form" : "MultiFormViewController",
        //"multi" : true,
        "submit": true,
        "attach": true,
        "value" : "5"
    ],
    [
        "title" : "Ребенок",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску ребенка, сбор свидетельских показаний. Усиление бдительности граждан",
        "submit": true,
        "attach": true,
        "value" : "6"
    ],
    [
        "title" : "Вещи",
        "help"  : "Цель запроса - просьба откликнуться нашедшего, либо всех кто видел. В комментарии можно указать сумму вознаграждения.",
        "submit": true,
        "value" : "7"
    ],
    [
        "title" : "Взять на буксир",
        "help"  : "Цель запроса - просьба отбуксировать ТС, до ближайшего населенного пункта либо сервиса.",
        "submit": true,
        "value" : "8"
    ],
    [
        "title" : "1 литр",
        "help"  : "Цель запроса - просьба поделиться горючим, с указанием ТС. Запрос не принимается в городской черте.",
        "submit": true,
        "value" : "9"
    ],
    [
        "title" : "Автостоп",
        "help"  : "Цель запроса - просьба откликнуться нашедшего, либо всех кто видел. В комментарии можно указать сумму вознаграждения.",
        "submit": true,
        "value" : "11"
    ],
    
    //очевидец
    [
        "title" : "Угон",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску авто. Усиление бдительности граждан.",
        "submit": true,
        "attach": true,
        "value" : "12"
    ],
    [
        "title" : "Разбой",
        "help"  : "Цель запроса - привлечь, как можно, большее количество людей к поиску преступников. Усиление бдительности граждан.",
        "form" : "MultiFormViewController",
        "multi" : true,
        "submit": true,
        "attach": true,
        "value" : "13"
    ],
    [
        "title": "Пропажа ребенка",
        "help"  : "",
        "submit": true,
        "attach": true,
        "value": "14"
    ],
    [
        "title": "Пропажа вещи",
        "help"  : "",
        "submit": true,
        "value": "15"
    ],
    [
        "title" : "Скрылся с места ДТП",
        "help"  : "",
        "submit": true,
        "attach": true,
        "value" : "16"
    ],
    [
        "title" : "Похищение",
        "help"  : "",
        "attach": true,
        "submit": true,
        "value" : "17"
    ],
    [
        "title" : "Хулиганство",
        "help"  : "",
        "form" : "MultiFormViewController",
        "multi" : true,
        "submit": true,
        "attach": true,
        "value" : "18"
    ]
]