class MenuItem{
    
    //пункты меню
    var navi = ["Справка", "Справочники", "Группы", "Ассоциации", "Документы", "Разное", "Аналитика"]
    
    // подпункты, у каждого уникальный номер
    var sections = ["Содержание", "О Программе", "Места работы", "Должности", "Ученые степени", "Ученые звания", "Преподаватели", "Группы", "Специальности", "Факультеты", "Призы", "Города", "Уч. Заведения", "Мастер классы", "Участники", "Волонтеры", "Места работы преподавателя", "Должности преподавателя", "Ученые степени преподавателя", "Ученые звания преподавателя", "Преподаватели на мастер классах", "Волонтеры на мастер классах", "Призы участника", "Участники на мастер классах", "Экспорт данных", "Настройка", "Смена пароля", "Админ-зона", "Диаграмма данных", "Диаграмма изменений", "Диаграмма записей на мастер-классы"]
    // подпункты в ед. числе
    var section = ["Содержание", "О Программе", "Место работы", "Должность", "Ученая степень", "Ученое звание", "Преподаватель", "Группа", "Специальность", "Факультет", "Приз", "Город", "Уч. Заведение", "Мастер класс", "Участник", "Волонтер", "Места работы преподавателя", "Должности преподавателя", "Ученые степени преподавателя", "Ученые звания преподавателя", "Преподаватели на мастер классах", "Волонтеры на мастер классах", "Призы участника", "Участник на мастер классе", "Экспорт данных", "Настройка", "Смена пароля", "Админ-зона"]
    
    //номер секции в меню и название таблицы
    var table_names = [2:"place_works", 3:"position_works", 4:"academic_degrees", 5:"academic_titles", 6:"teachers", 7:"study_groups", 8:"specialties", 9:"faculties", 10:"prizes", 11:"cities", 12:"edu_instituts", 13:"master_classes", 14:"participants", 15:"volunteers", 16:"teachers_place_works", 17:"teachers_position_works", 18:"teachers_academic_degrees", 19:"teachers_academic_titles", 20:"teachers_master_classes", 21:"volunteers_master_classes", 22:"prizes_participants", 23:"participants_master_classes"]
    
    lazy var names: [String: Int] = Dictionary(uniqueKeysWithValues: table_names.map { ($1, $0) })
    
    //таблица связка и номера секции родителей (ассоциации - где мы: какие связи)
    lazy var table_id_id: [Int: [Int]] =
    [
        names["participants_master_classes"]!: [names["participants"]!, names["master_classes"]!],
        names["prizes_participants"]!: [names["prizes"]!, names["participants"]!],
        names["teachers_academic_degrees"]!: [names["teachers"]!, names["academic_degrees"]!],
        names["teachers_academic_titles"]!: [names["teachers"]!, names["academic_titles"]!],
        names["teachers_place_works"]!: [names["teachers"]!, names["place_works"]!],
        names["teachers_position_works"]!: [names["teachers"]!, names["position_works"]!],
        names["teachers_master_classes"]!: [names["teachers"]!, names["master_classes"]!],
        names["volunteers_master_classes"]!: [names["volunteers"]!, names["master_classes"]!]
    ]
    
    lazy var  id_title_type =
    [
        names["place_works"]!, names["position_works"]!,
        names["academic_degrees"]!, names["academic_titles"]!,
        names["study_groups"]!, names["specialties"]!,
        names["faculties"]!, names["prizes"]!,
        names["cities"]!, names["edu_instituts"]!
    ]
    
    //названия столбцов в таблице связке (ассоциации - где действие: какие столбы)
    lazy var table_id_name: [Int: [String]] =
    [
        names["participants_master_classes"]!: ["id_participant", "id_master_class"],
        names["prizes_participants"]! :["id_prize", "id_participant"],
        names["teachers_academic_degrees"]!: ["id_teacher", "id_academic_degree"],
        names["teachers_academic_titles"]!: ["id_teacher", "id_academic_title"],
        names["teachers_place_works"]!: ["id_teacher", "id_place_work"],
        names["teachers_position_works"]!: ["id_teacher", "id_position_work"],
        names["teachers_master_classes"]!: ["id_teacher", "id_master_class"],
        names["volunteers_master_classes"]!: ["id_volunteer", "id_master_class"]
    ]
    
    //для удаления, какие секции обновить в data (где удалили: что обновить)
    lazy var reference_books: [Int: [Int]] = [
        names["place_works"]!: [names["teachers_place_works"]!],
        names["position_works"]!: [names["teachers_position_works"]!],
        names["academic_degrees"]!: [names["teachers_academic_degrees"]!],
        names["academic_titles"]!: [names["teachers_academic_titles"]!],
        names["teachers"]!: [names["teachers_master_classes"]!],
        names["study_groups"]!: [names["volunteers"]!],
        names["specialties"]!: [names["volunteers"]!],
        names["faculties"]!: [names["volunteers"]!],
        names["prizes"]!: [names["prizes_participants"]!],
        names["cities"]!: [names["participants"]!],
        names["edu_instituts"]!: [names["participants"]!],
        names["master_classes"]!: [
                                    names["teachers_master_classes"]!,
                                    names["volunteers_master_classes"]!,
                                    names["participants_master_classes"]!
                                  ],
        names["participants"]!: [names["prizes_participants"]!, names["participants_master_classes"]!],
        names["volunteers"]!: [names["volunteers_master_classes"]!],
    ]
}


class Messages{
    let names = MenuItem().names
    
    var messages_about = ["Это главный раздел для получения информации о программе и помощи.\nО программе: Сведения о названии, версии, разработчике.\nСправка: Вызов основного руководства пользователя.", "Это раздел для ведения нормативно-справочной информации (справочников) — основы системы.\nСправочники представляют собой обьекты, которые не зависят от других. Их можно добавлять (Нажимаем '+' в меню и появляется форма для заполнения), редактировать (аналогично добавлению, только форма будет заполнена) и удалять. Так же присутствует возможность найти обьект по названию (в навигации есть иконка / поле поиска, в зависимости от размера экрана). Некоторые справочники могут быть не доступны из-за отсутствия прав доступа.", "Этот раздел для управления группами объектов - волонтеры и участники, обьекты которые хранят в себе данные о других.\nВозможности: удалить / изменить / добавить", "Раздел для настройки связей и отношений между объектами системы.\nАссоциации представляют собой связь между двумя обьектами, возможности: удалить / изменить / добавить.", "Раздел для работы с SQL-запросами, то есть пользователь обращается напрямую к базе данных, видит результат на экране и при необходимости может экспортировать ответ в файл", "Раздел для прочих, технических или редко используемых функций.\nПользователь может сменить пароль, настроить возможности приложения."]
    
    lazy var messages: [Int: [String] ] = [
        names["master_classes"]!: ["Название: ", "Целевая аудитория: ", "Описание: ", "Максимальное число участников: ", "Аудитория проведения: ", "Ссылка на занятие: "],
        names["participants"]!: ["Имя: ", "Фамилия: ", "Отчество: ", "Класс обучения: ", "Формат участия: ", "Почта: ", "Телефон: ", "Согласие: ", "Результат диктанта: ", "Сертификат: ", "Город: ", "Учебное заведение: "],
        names["volunteers"]!: ["Имя: ", "Фамилия: ", "Отчество: ", "Курс обучения: ", "Группа: ", "Специальность: ", "Факультет: "] ]
}


