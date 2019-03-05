//
//  ExtraForms.swift
//  GPSTracking
//
//  Created by denis zaytcev on 6/16/15.
//  Copyright (c) 2015 denis zaytcev. All rights reserved.
//

import Foundation
import XLForm

protocol ArrayRepresentable {
    typealias ArrayType
    func toArray() -> [ArrayType]
}

extension Range : ArrayRepresentable {
    func toArray() -> [T] {
        return [T](self)
    }
}

typealias EventExtraFieldsParams = [String: [String: AnyObject]]

let ExtraFields: EventExtraFieldsParams = [
    "markAuto" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPush,
        "title"             : "Марка",
        "selectorOptions"   : MarkAutoData
    ],
    "modelAuto": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPush,
        "title"             : "Модель",
        "dependenciesSelector" : ModelAutoData(),
        "dependenciesField" : "markAuto"
    ],
    "bodyAuto":[
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPush,
        "title"             : "Кузов",
        "selectorOptions"   : BodyAutoData
    ],
    "colorAuto":[
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewColor,//исправить на цвет
        "rowType"           : XLFormRowDescriptorTypeColor,
        "title"             : "Цвет",
        "action"            : [ "viewControllerStoryboardId" : "ColorViewController"]
    ],
    "yearAuto" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Год выпуска",
        "selectorOptions"   : ["до 1980"] + (1980...2015).toArray().map{"\($0)"}
    ],
    "timeStealingFrom" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeTime,
        "valueTransformer"  : "StringToDate",
        "title"             : "Время угона с",
        "transform"         : "Time"
    ],
    "timeStealingTo" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeTime,
        "valueTransformer"  : "StringToDate",
        "title"             : "Время угона до",
        "transform"         : "Time"
    ],
    "timeAccident" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeTime,
        "valueTransformer"  : "StringToDate",
        "title"             : "Время ДТП",
        "transform"         : "Time"
    ],
    "numberAuto" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeText,
        "title"             : "Гос. номер"
    ],
    "sex" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Пол",
        "selectorOptions"   : ["Мужской", "Женский"]
    ],
    "fuel" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Марка топлива",
        "selectorOptions"   : ["ДТ", "АИ-80", "АИ-92", "АИ-95", "АИ-98"]
    ],
    "сolorhair" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Цвет волос",
        "selectorOptions"   : [ "Блондин", "Русый", "Шатен", "Брюнет"]
    ],
    "coloreye" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Цвет глаз",
        "selectorOptions"   : EyeColors
    ],
    "clothing" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeTextView,
        "title"             : "Одежда"
    ],
    "which saw" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeTextView,
        "title"             : "Где видели"
    ],
    "when they saw" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeDate,
        "title"             : "Когда последний раз видели",
        "valueTransformer"  : "StringToDate",
        "transform"         : "Date"
    ],
    "special features" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeTextView,
        "title"             : "Особые приметы"
    ],
    "height": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Рост",
        "selectorOptions"   : ["до 70", "70-90", "90-110", "110-120", "120-140", "140-160", "свыше 160"]  
    ],
    "age": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Возраст",
        "selectorOptions"   : ["до года", "1-3", "3-5", "5-7", "7-9", "11-13", "14-18", "свыше 18"]
    ],
    "body": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Комплекция",
        "selectorOptions"   : ["Худой", "Средний", "Крупный"]
    ],
    "name": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeText,
        "title"             : "Наименование"
    ],
    "where missing": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeTextView,
        "title"             : "Где пропал"
    ],
    "reward": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeTextView,
        "title"             : "Вознаграждение"
    ],
    "telephone": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypePhone,
        "title"             : "Телефон"
    ],
    "destination" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeTextView,
        "title"             : "Пункт назначения"
    ],
    "VINAuto" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeText,
        "title"             : "VIN"
    ],
    "how many people" :[
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Сколько человек",
        "selectorOptions"   : ["1", "2", "3", "4"]
    ],
    "price" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorAlertView,
        "title"             : "Платно",
        "selectorOptions"   : ["Да", "Нет"]
    ],
    "description" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeTextView,
        "title"             : "Описание"
    ],
    "cable" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorAlertView,
        "title"             : "Трос",
        "selectorOptions"   : ["Есть", "Нет"]
    ],
    "age wrong" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Возраст",
        "selectorOptions"   : ["до 20", "20-25", "25-30", "30-35", "35-40", "свыше 40"]
    ],
    "height wrong" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Рост",
        "selectorOptions"   : ["до 165", "165-170", "170-175", "175-180", "180-185", "185-190", "свыше 190"]
    ],
    "body wrong" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Комплекция",
        "selectorOptions"   : ["Худой", "Средний", "Крупный"]
    ],
    "nations":[
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Национальность",
        "selectorOptions"   : ["Славяне", "Кавказцы", "Азиаты", "Арабы", "Среднеазиаты", "Другая"]
    ],
    "nation":[
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Национальность",
        "selectorOptions"   : ["Славянин", "Кавказец", "Азиат", "Араб", "Среднеазиат", "Другая"]
    ],
    "victim" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Потерпевший",
        "action"            : [ "viewControllerStoryboardId" : "CommonFormViewController"],
        "fields"            : [
            "markAuto",
            "modelAuto",
            "bodyAuto",
            "yearAuto",
            "colorAuto",
            "numberAuto"
        ]
    ],
    "victimWithTime" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Потерпевший",
        "action"            : [ "viewControllerStoryboardId" : "CommonFormViewController"],
        "fields"            : [
            "markAuto",
            "modelAuto",
            "bodyAuto",
            "yearAuto",
            "colorAuto",
            "numberAuto",
            "timeAccident"
        ]
    ],
    "auto" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Авто нападавших",
        "action"            : [ "viewControllerStoryboardId" : "CommonFormViewController"],
        "fields"            : [
            "markAuto",
            "modelAuto",
            "bodyAuto",
            "colorAuto",
            "numberAuto"
        ]
    ],
    "stage" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Этаж",
        "selectorOptions"   : (-2...20).toArray().map{"\($0)"}
    ],
    "with man": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Предпочтения",
        "selectorOptions"   : ["C мужчиной", "C женщиной"]
    ],
    "can wait" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Могу ждать",
        "selectorOptions"   : ["5 мин", "10 мин", "15 мин", "20 мин"]
    ],
    "contacts" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPush,
        "title"             : "Контакт",
        "action"            : [ "viewControllerStoryboardId" : "PeopleFormViewController"]
    ],
    "count hijack" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Число потерпевших",
        "selectorOptions"   : (1...3).toArray().map{"\($0)"}
    ],
    "count reaver" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Число нападавших",
        "selectorOptions"   : (1...3).toArray().map{"\($0)"}
    ],
    "hijack" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Потерпевший",
        "action"            : [ "viewControllerStoryboardId" : "CommonFormViewController"],
        "fields"            : [
            "count hijack",
            "sex",
            "age"
            
        ]
    ],
    "reaver" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Похитители",
        "action"            : [ "viewControllerStoryboardId" : "CommonFormViewController"],
        "fields"            : [
            "count reaver",
            "age wrong",
            "height wrong",
            "body wrong",
            "nations",
            "special features",
            "auto"
        ]
    ],
    "culprit" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Виновник",
        "action"            : [ "viewControllerStoryboardId" : "CommonFormViewController"],
        "fields"            : [
            "markAuto",
            "modelAuto",
            "bodyAuto",
            "yearAuto",
            "colorAuto",
            "numberAuto"
        ]
    ],
    "common reaver" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Общая информация о преступниках",
        "action"            : [ "viewControllerStoryboardId" : "CommonFormViewController"],
        "fields"            : [
            "count reaver",
            "age wrong",
            "height wrong",
            "body wrong",
            "nations",
            "special features"
        ]
    ],
    "multi items" : [
        "format"        : CommonFormViewControllerFormat.Multi.rawValue,
        "view"          : kStaticRowViewArray,
        "titleButton"   : "Добавить правонарушителя",
        "titleRow"      : "Правонарушитель",
        "title"         : "Правонарушители",
        "maxCount"      : 4,
        "fields"        : [
            "age wrong",
            "height wrong",
            "body wrong",
            "nation",
            "special features",
        ]
    ]
]