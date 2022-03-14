import { retryFetch } from '$lib/components/Hooks/Custom.js'

const fetchOpts = {
  method: "get",
  mode: "cors",
  cache: 'no-cache',
}

const joinOpts = (opts) => {
  let query = ""

  if (opts) {
    o = Object.keys(opts).map((val) => {
      return encodeURIComponent("${val}=${opts[val]}")
    })
    query = "?" + o.join("&")
  }

  return query
}

const CheckRequest = async (url, addOpts = {}) => {
  if (url) {
    let output = await fetch(
      `/api/v1/${url}`,
      {
        ...fetchOpts,
        ...addOpts,
      }
    )
    return output
  }
  return null
}

const ApiRequest = async (url, addOpts = {}) => {
  if (url) {
    let output = await fetch(
      `/api/v1/${url}`,
      {
        ...fetchOpts,
        ...addOpts,
      }
    ).then(data => data.json())
    return output
  }
  return null
}

const retryApiRequest = async (url, user, subscriber, addOpts = {}) => {
  if (url && user) {
    let output = await retryFetch(
      `/api/v1/${url}`,
      {
        ...fetchOpts,
        headers: {
          'Authorization': `Bearer ${user.access_token}`,
        },
        ...addOpts,
      },
      subscriber
    )
    return output
  }
  return null
}

// users, companies, reviews, events, etc.
export const getAllRecords = async (slug, opts) => {
  let output = await ApiRequest(`${slug}/${joinOpts(opts)}`)
  return output
}

export const getAssetsBySlug = async (slug) => {
  let output = await ApiRequest(`assets/${slug}/`)
  return output
}

export const getUserByLogin = async (login) => {
  let output = await ApiRequest(`user/${login}/`)
  return output
}

export const getUserReviews = async (user, subscriber) => {
  let output = await retryApiRequest(`reviews/?customer=${user.login}`, user, subscriber)
  return output
}

export const getUserEvents = async (user, subscriber) => {
  let output = await retryApiRequest(`events/?customer=${user.login}`, user, subscriber)
  return output
}

export const getAvatarByUser = async (user) => {
  let output = await CheckRequest(`avatar/${user.login}?image=${user.avatar_file_name}`)
  return output
}

export const updateUserProfile = async (user, subscriber, body) => {
  let output = await retryApiRequest(`user/${user.login}/`, user, subscriber,
  {
    body,
    method: "put",
  })
  return output
}

export const getCompanyProfile = async (user, subscriber) => {
  let output = await retryApiRequest(`${user.login}/company/`, user, subscriber)
  return output
}

export const getCompanyEvents = async (user, subscriber, company) => {
  let output = await retryApiRequest(`events/?company_name=${company}`, user, subscriber)
  return output
}

export const getCompanyReviews = async (user, subscriber, company) => {
  let output = await retryApiRequest(`reviews/?company_name=${company}`, user, subscriber)
  return output
}

export const authenticateUser = async (body) => {
  let output = await ApiRequest(`auth/`, {
    method: "post",
    body,
  })
  return output
}

export const getUserSessions = async (user, subscriber) => {
  let output = await retryApiRequest(`sessions/${user.login}/`, user, subscriber)
  return output
}

export const removeUser = async(user, subscriber) => {
  let output = await retryApiRequest(`user/${user.login}/`, user, subscriber, {
    method: "delete",
  })
  return output
}

export const signOutUser = async(user, subscriber) => {
  let output = await retryApiRequest(`auth/`, user, subscriber, {
    method: "delete",
  })
  return output
}

export const removeSession = async (token_id, user, subscriber) => {
  let output = await retryApiRequest(`session/${token_id}`, user, subscriber, {
    method: "delete",
  })
  return output
}

export const confirmUser = async (code) => {
  let output = await ApiRequest(`confirm/?code=${code}`, {
    method: "get",
  })
  return output
}

export const restoreUser = async (code) => {
  let output = await ApiRequest(`restore/${code}/`, {
    method: "put",
  })
  return output
}

export const createUser = async (body) => {
  let output = await ApiRequest(`users/`, {
    method: "post",
    body,
  })
  return output
}

export const retrieveSession = async () => {
  let output = await ApiRequest(`auth/`, {
    method: "put",
  })
  return output
}

export const setCompanyProfile = async (user, subscriber, path, method, body) => {
  let output = await retryApiRequest(path, user, subscriber, {
    method,
    body,
  })
  return output
}