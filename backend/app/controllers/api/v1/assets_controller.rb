class Api::V1::AssetsController < ApplicationController

  def index
    begin 
      assets = Assets.find_by(slug: params[:slug])
      escape_with!(:assets, :not_found, :ok) unless assets
      render json: except_data!(assets), status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  def init
    begin
      key = init_parameters[:key]
      escape_with!(:auth, :unauthorized_access, :ok) unless key.eql?(ENV["SECRET_KEY"])
      escape_with!(:assets, :not_create, :ok) unless Assets.find_or_create_by(type: "Services", content: {
        elements: [
          "Стандартная уборка помещений", 
          "Генеральная уборка",
          "Уборка после ремонта и строительства",
          "Химчистка ковров",
          "Уборка офисов",
          "Химчистка мебели и покрытий",
          "Промышленная уборка",
          "Уборка бассейна"
        ]
      })
    
      escape_with!(:assets, :not_create, :ok) unless Assets.find_or_create_by(type: "Status", content: {
        new: "Новый",
        accepted: "Подтверждён",
        canceled: "Отменён",
      })
    
      escape_with!(:assets, :not_create, :ok) unless Assets.find_or_create_by(type: "odds", content: {
        standard: 1,
        large: 1.2,
        restrooms: 1.5,
      })

      escape_with!(:assets, :not_create, :ok) unless Assets.find_or_create_by(type: "Countries", content: {
        elements: ["Афганистан",
          "Албания",
          "Алжир",
          "Американское Самоа",
          "Андорра",
          "Ангола",
          "Ангилья",
          "Антигуа и Барбуда",
          "Аргентина",
          "Армения",
          "Аруба",
          "Австралия",
          "Австрия",
          "Азербайджан",
          "Бангладеш",
          "Барбадос",
          "Багамы",
          "Бахрейн",
          "Беларусь",
          "Бельгия",
          "Белиз",
          "Бенин",
          "Бермуды",
          "Бутан ",
          "Боливия",
          "Босния и Герцеговина",
          "Ботсвана",
          "Бразилия",
          "Британская территория в Индийском океане",
          "Британские Виргинские острова",
          "Бруней-Даруссалам",
          "Болгария",
          "Буркина-Фасо",
          "Бирма",
          "Бурунди",
          "Камбоджа",
          "Камерун",
          "Канада",
          "Кабо-Верде",
          "Каймановы острова",
          "Центральноафриканская Республика",
          "Чад",
          "Чили",
          "Китай",
          "Остров Рождества",
          "Кокосовые (Килинг) острова",
          "Колумбия",
          "Коморские острова",
          "Конго-Браззавиль",
          "Конго-Киншаса",
          "Острова Кука",
          "Коста-Рика",
          "Хорватия",
          "Кюрасао",
          "Кипр",
          "Чехия",
          "Дания",
          "Джибути",
          "Доминика",
          "Доминиканская Республика ",
          "Восточный Тимор",
          "Эквадор",
          "Сальвадор",
          "Египет",
          "Экваториальная Гвинея",
          "Эритрея",
          "Эстония",
          "Эфиопия",
          "Фолклендские острова",
          "Фарерские острова",
          "Федеративные Штаты Микронезии",
          "Фиджи",
          "Финляндия",
          "Франция",
          "Французская Гвиана",
          "Французская Полинезия",
          "Французские Южные земли",
          "Габон",
          "Гамбия ",
          "Грузия",
          "Германия",
          "Гана",
          "Ги braltar",
          "Греция",
          "Гренландия",
          "Гренада",
          "Гваделупа",
          "Гуам",
          "Гватемала",
          "Гернси",
          "Гвинея",
          "Гвинея-Бисау",
          "Гайана",
          "Гаити",
          "острова Херд и Макдональд",
          "Гондурас",
          "Гонконг",
          "Венгрия",
          "Исландия",
          "Индия",
          "Индонезия",
          "Ирак",
          "Ирландия",
          "остров Человек",
          "Израиль",
          "Италия",
          "Ямайка",
          "Япония",
          "Джерси",
          "Иордания",
          "Казахстан",
          "Кения",
          "Кирибати",
          "Кувейт",
          "Кыргызстан",
          "Лаос",
          "Латвия",
          "Ливан",
          "Лесото",
          "Либерия",
          "Ливия",
          "Лихтенштейн",
          "Литва",
          "Люксембург",
          "Макао",
          "Македония",
          "Мадагаскар",
          "Малави",
          "Малайзия",
          "Мальдивы",
          "Мали",
          "Мальта",
          "Маршалловы острова",
          "Мартиника",
          "Мавритания",
          "Маврикий",
          "Майотта",
          "Мексика",
          "Молдова",
          "Монако",
          "Монголия",
          "Черногория",
          "Монтсеррат",
          "Марокко",
          "Мозамбик",
          "Намибия",
          "Науру",
          "Непал",
          "Нидерланды",
          "Новая Каледония",
          "Новая Зеландия",
          "Никарагуа ",
          "Нигер",
          "Нигерия",
          "Ниуэ",
          "остров Норфолк",
          "Северные Марианские острова",
          "Норвегия",
          "Оман",
          "Пакистан",
          "Палау",
          "Панама",
          "Папуа-Новая Гвинея",
          "Парагвай",
          "Перу",
          "Филиппины",
          "острова Питкэрн",
          "Польша",
          "Португалия",
          "Пуэрто-Рико",
          "Катар",
          "Руюнион",
          "Румыния",
          "Россия",
          "Руанда",
          "Сен-Бартельми",
          "Остров Святой Елены",
          "Сент-Китс и Невис",
          "Сент-Лу cia",
          "Сен-Мартен",
          "Сен-Пьер и Микелон",
          "Сент-Винсент",
          "Самоа",
          "Сан-Марино",
          "Сан-Том? и Принсипи",
          "Саудовская Аравия",
          "Сенегал",
          "Сербия",
          "Сейшельские острова",
          "Сьерра-Леоне",
          "Сингапур",
          "Синт-Мартен",
          "Словакия",
          "Словения",
          "Соломоновы острова",
          "Сомали",
          "Южная Африка",
          "Южная Грузия",
          "Южная Корея",
          "Испания",
          "Шри-Ланка",
          "Судан",
          "Суринам",
          "Шпицберген и Ян-Майен",
          "Швеция",
          "Свазиленд",
          "Швейцария",
          "Сирия",
          "Тайвань",
          "Таджикистан",
          "Танзания",
          "Таиланд",
          "Того",
          "Токелау",
          "Тонга",
          "Тринидад и Тобаго",
          "Тунис",
          "Турция",
          "Туркменистан",
          "острова Теркс и Кайкос",
          "Тувалу",
          "Уганда",
          "Украина",
          "Объединенные Арабские Эмираты ",
          "Великобритания",
          "США",
          "Уругвай",
          "Узбекистан",
          "Вануату",
          "Ватикан",
          "Вьетнам",
          "Венесуэла",
          "Уоллис и Футуна",
          "Западная Сахара",
          "Йемен",
          "Замбия",
          "Зимбабве",
        ]
      })
      render json: {message: "Все начальные данные были успешно установлены"}, status: :ok and return
    rescue ApiError => e
      render_api_error(e)
    end
  end

  private
  def init_parameters
    params.permit(:key)
  end
end
