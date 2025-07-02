
const apiUrlCount = 'https://20fejhrl09.execute-api.us-east-2.amazonaws.com/count';
const apiUrlIncrement = 'https://20fejhrl09.execute-api.us-east-2.amazonaws.com/increment'; 

function hasVisited() {
  return document.cookie.split(';').some(cookie => cookie.trim().startsWith('visited='));
}

if (hasVisited()) {
  console.log('User has visited before.');
    fetch(apiUrlCount)
  .then(response => response.json())
  .then(data => {
    document.getElementById('visitor-count').innerText = data.count;
  })
  .catch(error => {
    document.getElementById('visitor-count').innerText = 'Error';
    console.error('Error fetching visitor count:', error);
  });
  
} else {
  console.log('First time visitor.');
  document.cookie = "visited=true; max-age=" + 60 * 60 * 24 * 365 + "; path=/";

  fetch(apiUrlIncrement)
  .then(response => response.json())
  .then(data => {
    document.getElementById('visitor-count').innerText = data.count;
  })
  .catch(error => {
    document.getElementById('visitor-count').innerText = 'Error';
    console.error('Error fetching visitor count:', error);
  });
  
}

