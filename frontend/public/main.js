
const apiUrl = 'https://3z3w4dxqm4.execute-api.us-east-2.amazonaws.com/count';

fetch(apiUrl)
  .then(response => response.json())
  .then(data => {
    document.getElementById('visitor-count').innerText = data.count;
  })
  .catch(error => {
    document.getElementById('visitor-count').innerText = 'Error';
    console.error('Error fetching visitor count:', error);
  });