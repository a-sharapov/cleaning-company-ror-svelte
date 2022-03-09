import { browser } from '$app/env'
import { writable } from 'svelte/store'

export const prepareFormData = (data, object, defaultRemovedFields = null) => {
  Object.keys(object).map(key => {
    data.get(key) === "" ? data.delete(key) : void -1
  })

  if (defaultRemovedFields) {
    let defaults = defaultRemovedFields.split(',')
    defaults.map(key => {
      data.delete(key.split())
    })
  }

  return data
}

export const message = writable({
  content: null,
  type: "info",
})

export const getUserFromStorage = () => {
  let user
  browser ? user = window?.localStorage.getItem("user") ? window?.localStorage.getItem("user") : window?.sessionStorage.getItem("user") : user = null
  if (!!user) {
    return JSON.parse(user)
  } else {
    return false
  }
}

export const user = writable(getUserFromStorage())

export const removeUserFromStorage = () => {
  switch (true) {
    case !!window.localStorage.getItem("user"):
      window?.localStorage.removeItem("user")
    default:
      window.sessionStorage.removeItem("user")
  }
  return
}

export const setUserInStorage = (user, remember) => {
  if (user) {
    window?.sessionStorage.setItem("user", JSON.stringify(user))
    if (remember) {
      window?.localStorage.setItem("user", JSON.stringify(user))
    }
    return true
  }
  return false
}

export const remembered = () => {
  if (window?.localStorage.getItem("user")) {
    return true
  }
  return false
}

export const messageProcessor = (result) => {
  let assets,
      message = {
        type: "info",
        content: `<p>${result.message}</p>`,
      }

  switch (true) {
    case !!result.error:
      message.content = result.error
      message.type = "error"
      break
    case !!result.assets:
      Array.isArray(result.assets) ? assets = `<ul><li>${result.assets.join("</li><li>")}</li></ul>` : assets = `<p>${result.assets}</p>`
      message.type = "error"
      message.content = `<p>${result.message}:</p>` + assets
      break
  }

  return message
}

export const retryFetch = async (url, options, user) => {
  let count = 0,
      maxTries = 3,
      retry = true,
      result,
      usr,
      opts = {
        ...options
      }

  user.subscribe(value => {
    usr = value
  })

  while (retry) {
    result = await fetch(url, opts).then(response => response.json())

    if (result && result.assets === "retrieve") {
      let resign = await fetch("/api/v1/auth/", {
        method: "put",
        cache: 'no-cache',
        mode: 'cors',
      }).then(response => response.json())
      if (resign.user) {
        let updateSession = setUserInStorage({...usr, ...resign.user}, remembered())
        if (updateSession) {
          retry = true
          user.set(getUserFromStorage())
          opts.access_token = usr.access_token
        } else {
          retry = false
          return {
            message: "Попытка создания локальной сессии завершилась неудачей",
            assets: "Проверьте настройки безопасности системы и браузера",
          }
        }
      }
      if (++count == maxTries) {
        retry = false
        return {
          message: "Внимание! Попытка обновления сессии закончиалсь неудачей",
          assets: "Попробуйте запросить данные снова или перезагрузить страницу",
        }
      }
    } else {
      retry = false
      return result
    }
  }
}