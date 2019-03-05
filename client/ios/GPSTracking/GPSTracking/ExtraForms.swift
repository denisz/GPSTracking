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
    func toArray() -> [Element] {
        return [Element](self)
    }
}

typealias EventExtraFieldsParams = [String: [String: AnyObject]]


func components() -> NSDate {
    let calendar = NSCalendar.currentCalendar()
    let components = NSDateComponents()
    components.year = 1980
    
    return calendar.dateFromComponents(components)!
}

let minimumDate = components()

let kActionCommonForm = [ "viewControllerStoryboardId" : "CommonFormViewController"] as [String: String]
let kActionMapForm = [ "viewControllerStoryboardId" : "PointInMapViewController"] as [String: String]

let ExtraFields: EventExtraFieldsParams = [
    "colorAuto":[
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewColor,
        "rowType"           : XLFormRowDescriptorTypeColor,
        "title"             : "Цвет",
        "action"            : [ "viewControllerStoryboardId" : "ColorViewController"] as [String:String]
    ],
    "yearAuto" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Год выпуска",
        "selectorOptions"   : ["до 1980"] + (1980...2015).toArray().map{"\($0)"} as [String]
    ],
    "timeStealingFrom" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeTime,
        "valueTransformer"  : "StringToDate",
        "title"             : "Время происшествия с",
        "transform"         : "Time"
    ],
    "timeStealingTo" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeTime,
        "valueTransformer"  : "StringToDate",
        "title"             : "Время происшествия до",
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
        "selectorOptions"   : ["Мужской", "Женский"] as [String]
    ],
    "fuel" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Марка топлива",
        "selectorOptions"   : ["ДТ", "АИ-80", "АИ-92", "АИ-95", "АИ-98"] as [String]
    ],
    "сolorhair" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Цвет волос",
        "selectorOptions"   : [ "Блондин", "Русый", "Шатен", "Брюнет"] as [String]
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
        "minimumDate"       : minimumDate,
        "maximumDate"       : NSDate(),
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
        "selectorOptions"   : ["до 70 см", "70-90 см", "90-110 см", "110-120 см", "120-140 см", "140-160 см", "свыше 160 см"]  as [String]
    ],
    "age": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Возраст",
        "selectorOptions"   : ["до года", "1-3 года", "3-5 лет", "5-7 лет", "7-9 лет", "11-13 лет", "14-18 лет", "свыше 18 лет"] as [String]
    ],
    "body": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Комплекция",
        "selectorOptions"   : ["Худой", "Средний", "Крупный"] as [String]
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
        "rowType"           : XLFormRowDescriptorTypeText,
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
        //        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeMapView,
        "action"            : kActionMapForm,
        "sectionTitle"      : "Пункт назначения",
        "title"             : "Пункт назначения"
    ],
    "destinationSeparator" : [
        "format"            : CommonFormViewControllerFormat.Seperator.rawValue,
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
        "selectorOptions"   : ["1", "2", "3", "4"] as [String]
    ],
    "price" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorAlertView,
        "title"             : "Платно",
        "selectorOptions"   : ["Да", "Нет"] as [String]
    ],
    "description" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeTextView,
        "title"             : "Описание"
    ],
    "comment" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeTextView,
        "title"             : "Комментарий"
    ],
    "cable" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorAlertView,
        "title"             : "Трос",
        "selectorOptions"   : ["Есть", "Нет"] as [String]
    ],
    "age wrong" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Возраст",
        "selectorOptions"   : ["до 20 лет", "20-25 лет", "25-30 лет", "30-35 лет", "35-40 лет", "свыше 40 лет"] as [String]
    ],
    "height wrong" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Рост",
        "selectorOptions"   : ["до 165 см", "165-170 см", "170-175 см", "175-180 см", "180-185 см", "185-190 см", "свыше 190 см"] as [String]
    ],
    "name baby" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewDescription,
        "rowType"           : XLFormRowDescriptorTypeText,
        "title"             : "Имя"
    ],
    "body wrong" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Комплекция",
        "selectorOptions"   : ["Худой", "Средний", "Крупный"] as [String]
    ],
    "nations":[
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Национальность",
        "selectorOptions"   : ["Славяне", "Кавказцы", "Среднеазиаты", "Азиаты", "Арабы", "Другая"] as [String]
    ],
    "nation":[
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Национальность",
        "selectorOptions"   : ["Славянин", "Кавказец", "Среднеазиат", "Азиат", "Араб", "Другая"] as [String]
    ],
    "victim" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Потерпевший",
        "action"            : kActionCommonForm,
        "fields"            : [
            "newAuto",
            "yearAuto",
            "colorAuto",
            "numberAuto"
        ] as [String]
    ],
    "victimWithTime" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Потерпевший",
        "action"            : kActionCommonForm,
        "fields"            : [
            "newAuto",
            "yearAuto",
            "colorAuto",
            "numberAuto",
            "timeAccident"
        ] as [String]
    ],
    "victimWithFromTo" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Потерпевший",
        "action"            : kActionCommonForm,
        "fields"            : [
            "newAuto",
            "yearAuto",
            "colorAuto",
            "numberAuto",
            "timeStealingFrom",
            "timeStealingTo"
        ] as [String]
    ],
    "auto" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Авто нападавших",
        "action"            : kActionCommonForm,
        "fields"            : [
            "newAuto",
            "colorAuto",
            "numberAuto"
        ] as [String]
    ],
    "stage" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Этаж",
        "selectorOptions"   : (-2...20).toArray().map{"\($0)"} as [String]
    ],
    "with man": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Предпочтения",
        "selectorOptions"   : ["C мужчиной", "C женщиной"] as [String]
    ],
    "can wait" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Могу ждать",
        "selectorOptions"   : ["5 мин", "10 мин", "15 мин", "20 мин"] as [String]
    ],
    "contacts" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPush,
        "title"             : "Контакт",
        "action"            : [ "viewControllerStoryboardId" : "PeopleFormViewController"] as [String: String]
    ],
    "count hijack" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Число потерпевших",
        "selectorOptions"   : (1...3).toArray().map{"\($0)"} as [String]
    ],
    "count reaver" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Число нападавших",
        "selectorOptions"   : (1...3).toArray().map{"\($0)"} as [String]
    ],
    "age hijack" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Возраст",
        "selectorOptions"   : ["до 1 года", "2 года", "3 года", "4 года"] + (5...100).toArray().map{"\($0) лет"} as [String]
    ],
    "hijack" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Потерпевший",
        "action"            : kActionCommonForm,
        "fields"            : [
            "count hijack",
            "sex",
            "age hijack"
        ] as [String]
    ],    
    "reaver" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Похитители",
        "action"            : kActionCommonForm,
        "fields"            : [
            "count reaver",
            "age wrong",
            "height wrong",
            "body wrong",
            "nations",
            "special features",
            "auto"
        ] as [String]
    ],
    "culprit" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Виновник",
        "action"            : kActionCommonForm,
        "fields"            : [
            "newAuto",
            "yearAuto",
            "colorAuto",
            "numberAuto"
        ] as [String]
    ],
    "common reaver" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Общая информация о преступниках",
        "action"            : kActionCommonForm,
        "fields"            : [
            "count reaver",
            "age wrong",
            "height wrong",
            "body wrong",
            "nations",
            "special features"
        ] as [String]
    ],
    "multi items" : [
        "format"        : CommonFormViewControllerFormat.Multi.rawValue,
        "view"          : kStaticRowViewArray,
        "titleButton"   : "Добавить правонарушителя",
        "titleRow"      : "Правонарушитель",
        "title"         : "Правонарушители",
        "footer"        : "Cтрока заполняется в случае если количество нападавших 3 и более, и наблюдаются существенные различия в ростовых, весовых, возрастных и других показателях, а так же если потерпевший может описать особые приметы.",
        "maxCount"      : 4,
        "fields"        : [
            "age wrong",
            "height wrong",
            "body wrong",
            "nation",
            "special features",
        ] as [String]
    ],
    "who missing": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPush,
        "title"             : "Кто пропал",
        "selectorOptions"   : ["Кот(кошка)", "Собака(пес)", "Птица"] as [String]
    ],
    "nickname": [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeText,
        "title"             : "Кличка",
    ],
    
    "newAuto" :[
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Авто",
        "action"            : kActionCommonForm,
        "fields"            : [
            "categoryAuto",
            "newmodelAuto",
            "markaAuto"
        ] as [String]
    ],
    
    "categoryAuto" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPush,
        "title"             : "Категория",
        "selectorOptions"   : ["мотоцикл", "легковой", "легкий коммерческий", "грузовой", "автобус", "спецтехника" ] as [String]
    ],
    
    "newmodelAuto" : [
        "format"                : CommonFormViewControllerFormat.Single.rawValue,
        "view"                  : kStaticRowKeyValue,
        "rowType"               : XLFormRowDescriptorTypeSelectorPush,
        "title"                 : "Модель",
        "dependenciesSelector"  : CategoryAutoData() as [String: AnyObject],
        "dependenciesField"     : "categoryAuto"
    ],
    
    "markaAuto" : [
        "format"                : CommonFormViewControllerFormat.Single.rawValue,
        "view"                  : kStaticRowKeyValue,
        "rowType"               : XLFormRowDescriptorTypeSelectorPush,
        "title"                 : "Марка",
        "dependenciesSelector"  : ModelsData() as [String: AnyObject],
        "dependenciesField"     : "categoryAuto"
    ],
    
    "numberAuto culprit" : [
        "dependenciesField"  : "know reaver",
        "dependenciesVisible": true,
        "dependenciesValue"  : true,
        
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeText,
        "title"             : "Гос. номер"
    ],
    
    "newAuto culprit" :[
        "dependenciesField"  : "know reaver",
        "dependenciesVisible": true,
        "dependenciesValue"  : true,
        
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Авто",
        "action"            : kActionCommonForm,
        "fields"            : [
            "categoryAuto",
            "newmodelAuto",
            "markaAuto"
        ] as [String]
    ],
    
    "colorAuto culprit":[
        "dependenciesField"  : "know reaver",
        "dependenciesVisible": true,
        "dependenciesValue"  : true,

        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewColor,
        "rowType"           : XLFormRowDescriptorTypeColor,
        "title"             : "Цвет",
        "action"            : [ "viewControllerStoryboardId" : "ColorViewController"] as [String: String]
    ],
    
    "culprit with know" : [
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewObject,
        "rowType"           : XLFormRowDescriptorTypeButton,
        "title"             : "Виновник",
        "action"            : kActionCommonForm,
        "fields"            : [
            "know reaver",
            "color scratch",
            "height scratch",
            
            "newAuto culprit",
            "colorAuto culprit",
            "numberAuto culprit"
        ] as [String]
    ],
    
    "know reaver": [
        "format"    : CommonFormViewControllerFormat.Single.rawValue,
        "rowType"   : XLFormRowDescriptorTypeBooleanSwitch,
        "title"     : "Известен"
    ],
    
    "color scratch" : [
        "dependenciesField" : "know reaver",
        "dependenciesVisible": true,
        "dependenciesValue"  : false,
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowViewColor,
        "rowType"           : XLFormRowDescriptorTypeColor,
        "title"             : "Цвет ТС",
        "action"            : [ "viewControllerStoryboardId" : "ColorViewController"] as [String: String]
    ],
    
    "height scratch" : [
        "dependenciesField"  : "know reaver",
        "dependenciesVisible": true,
        "dependenciesValue"  : false,
        "format"            : CommonFormViewControllerFormat.Single.rawValue,
        "view"              : kStaticRowKeyValue,
        "rowType"           : XLFormRowDescriptorTypeSelectorPickerView,
        "title"             : "Высота царапины",
        "selectorOptions"   : (20...160).toArray().map{"\($0) см"} as [String]
    ]
]