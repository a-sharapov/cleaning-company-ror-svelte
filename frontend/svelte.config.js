
/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		floc: true,
		target: '#app',
		methodOverride: {
      allowed: ['PUT', 'PATCH', 'DELETE']
    },
	},
}

export default config
