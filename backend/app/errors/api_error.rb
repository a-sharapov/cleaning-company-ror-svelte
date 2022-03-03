class ApiError < StandardError
  MESSAGES = {
    api: {
      wrong_request: "Неверный тип запроса, проверьте данные",
      notification_send_failure: "Отрпавить уведомление не удалось, но действие завершилось успешно",
      activation_send_failure: "Не удалось отправить код активации, вы должны активировать учетную запись самостоятельно",
      new_password_send_failure: "Не удалось отправить новый пароль, попробуйте сделать это позже",
      invalid_request: "Проверьете введённые данные и попробуйте снова",
    },
    management: {
      banned: "Пользователь заблокирован",
    },
    assets: {
      not_found: "Доступ запрещён",
      not_create: "Невозможно развернуть начальные данные",
    },
    user: {
      created: "Пользователь успешно зарегестрирован в системе, проверьте SMS/email",
      not_exist: "Пользователь недоступен или ещё не был создан",
      not_found: "Нет пользователей для отображения",
      not_create: "Невозможно создать нового пользователя",
      not_update: "Невозможно обновить пользователя",
      not_remove: "Невозможно удалить пользователя",
      deleted: "Пользователь был успешно удалён из системы",
      new_password: "Пароль был сгенерирован и отправлен, проверьте SMS/email",
    },
    profiles: {
      not_exist: "Профиль компании недоступен или ещё не был создан",
      not_found: "Нет профилей для отображения",
      already_exist: "Профиль компании уже существует, вы можете изменить его",
    },
    reviews: {
      not_exist: "Отзыв недоступен или ещё не был создан",
      not_found: "Нет отзывов для отображения",
      already_exist: "Вы уже написали отзыв для этой компании",
    },
    events: {
      not_exist: "Событие недоступно или ещё не было создано",
      not_found: "Нет событий для отображения",
      already_exist: "Событие уже существует",
      not_remove: "Невозможно удалить событие",
      deleted: "Событие было успешно удалено",
    },
    attachments: {
      not_found: "Прикрепления не найдены",
    }, 
    token: {
      not_set: "Данные сигнатуры доступа не соответвуют действиетельности",
      token_expired: "Срок действия сигнатуры истек",
      missmatching: "Данные сигнатуры доступа не совпадают или отсутвуют",
    },
    auth: {
      update: "Сессия обновлена",
      not_update: "Невозможно обновить данные сессии",
      login_in: "Авторизация прошла успешно",
      session_updated: "Сессия была обновлена",
      user_not_exist: "Пользователь не существует",
      unauthorized_access: "Зафиксирована попытка несанкционированного доступа",
      password_incorrect: "Неверный пароль",
      confirmed: "Аккаунт успешно подтверждён, теперь вы можете использовать приложение в полном объёме",
      need_confirmation: "Необходимо подтвердить аккаунт",
      already_confirmed: "Аккаунт уже успешно подтверждён",
      not_confirmed: "Аккаунт не был подтверждён",
      not_login: "Невозможно авторизоваться",
      not_logout: "Невозможно деавторизоваться",
      blocked_until: "Ваш аккаунт был заблокирован на 1 час",
      forbidden: "Вы не можете получить доступ к этим данным",
      service_unavailable: "Сервис временно недоступен",
    }
  }

  attr_reader :type
  attr_reader :assets

  def initialize(message = "Error!", type = :unprocessable_entity, assets = nil)
    super(message)
    @type = type
    @assets = assets
  end
end