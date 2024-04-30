const form = document.getElementById('userForm');
const lambdaFunctionUrl = 'https://liakfrlhhwn47dsbtzphiwzsq40bdwtv.lambda-url.ap-south-1.on.aws/'; // Replace with your Lambda function's URL 

form.addEventListener('submit', (event) => {
  event.preventDefault(); // Prevent default form submission

  const firstName = document.getElementById('firstName').value;
  const lastName = document.getElementById('lastName').value;

  const payload = {
    body: JSON.stringify({ firstName, lastName }),
    httpMethod: "POST",
    headers: {
      "Content-Type": "application/json"
    }
  };

  fetch(lambdaFunctionUrl, payload)
    .then(response => {
      if (response.ok) {
        console.log('Success:', response);
      } else {
        console.error('Error:', response);
      }
    })
    .catch(error => console.error('Network error:', error));
});
