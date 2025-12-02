import axios from 'axios'

export default(service) => {
	if(service == 'expressed'){
	    return axios.create({
	        baseURL: (process.env.VUE_APP_EXPRESSED_BASE_URL !== undefined) ? process.env.VUE_APP_EXPRESSED_BASE_URL : '/api/express',
	        withCredentials: false,
	        headers: {
	            'Accept': 'application/json',
	            'Content-Type': 'application/json'
	        }
	    });
	}
	else if(service == 'happy'){
	    return axios.create({
	        baseURL: (process.env.VUE_APP_HAPPY_BASE_URL !== undefined) ? process.env.VUE_APP_HAPPY_BASE_URL : '/api/happy',
	        withCredentials: false,
	        headers: {
	            'Accept': 'application/json',
	            'Content-Type': 'application/json'
	        }
	    });
	}
	else if(service == 'bootstorage'){
	    return axios.create({
	        baseURL: (process.env.VUE_APP_BOOTSTORAGE_BASE_URL !== undefined) ? process.env.VUE_APP_BOOTSTORAGE_BASE_URL : '/api/bootstorage',
	        withCredentials: false,
	        headers: {
	            'Accept': 'application/json',
	            'Content-Type': 'application/json'
	        }
	    });
	}
}