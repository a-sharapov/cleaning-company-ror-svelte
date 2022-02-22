# cleaning-company-ror-svelte
## Индивидуальный проект на *Ruby on Rails* (backend) + *SvelteKit* (frontend)

### Для запуска потребуется установленный Docker.
Устанавливать **ruby, rails, node.js и mongo** не требуется.

Переменные для запуска приложения должны быть размещены в файле **./backend/.env**

> #Необходимые параметры:\
  SERVICE_NAME="Cleaning portal"\
  HOST_NAME="localhost"\
  SECRET_KEY="SecretKey"\
  WRONG_ATTEMPTS_COUNT=3\
  SMTP_HOST=smtp.yandex.ru\
  SMTP_PORT=587\
  SMTP_LOGIN=mailer@yandex.ru\
  SMTP_SECRET=passwordformailer\
  TWILIO_ACCOUNT_SID=IDOFTWILIOACCOUNTDATA\
  TWILIO_AUTH_TOKEN=TWILIOAUTHTOKENDATA\
  TWILIO_NUMBER="+123456789"


Старт приложения локально:

> docker-compose up --build

После успещного запуска приложение будет доступна по адресам:

> localhost - frontend\
> localhost/api - backend

Точки входа:

> localhost/api/v1

Для нормальной работы приложения потребуется инициализация ассетов (предустановленных данных):

> localhost/api/v1/assets/init?key=SecretKey

Приложение запущено и готово к использованию

### Примечания

Сертификат и ключ для работы SSL должны быть размещены в категории **./certs/**

Так как в качестве reverse-proxy используется *nginx* содержимое файла **certificate.crt** должно включать:
- тело сертификата
- CA_bundle