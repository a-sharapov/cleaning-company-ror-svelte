import { browser } from '$app/env'
import { goto } from '$app/navigation'
import { writable } from 'svelte/store'
import { retrieveSession } from '$lib/components/Utils/Requests.js'

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
      // debugger
      // console.group(`RetryFetch to ${url}`)
      // console.log("Need to retry: ", !!result.assets)
      // console.log("Retry status:", retry)
      // console.log("Current step:", count+1)
      // console.groupEnd(`RetryFetch to ${url}`)
    if (!!result.assets && result.assets === "retrieve") {
      let resign = await retrieveSession()

      if (!!resign.user) {
        retry = true
        setUserInStorage({...usr, ...resign.user}, remembered())
        user.set(getUserFromStorage())
        opts.headers.Authorization = `Bearer ${resign.user.access_token}`
      }

      if (resign.assets === "unauthorize") {
        removeUserFromStorage()
        user.set(null)
        setTimeout(async () => { 
          goto("/")
        }, 5e2)
      }

      if (++count == maxTries) {
        retry = false
      }
    } else {
      retry = false
      return result
    }
  }
}