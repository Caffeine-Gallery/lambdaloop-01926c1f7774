import { backend } from 'declarations/backend';

document.addEventListener('DOMContentLoaded', () => {
    const expressionInput = document.getElementById('expression-input');
    const evaluateBtn = document.getElementById('evaluate-btn');
    const resultDiv = document.getElementById('result');

    evaluateBtn.addEventListener('click', async () => {
        const expression = expressionInput.value.trim();
        if (expression) {
            try {
                resultDiv.textContent = 'Evaluating...';
                const result = await backend.evaluate(expression);
                resultDiv.innerHTML = result.replace(/\n/g, '<br>');
            } catch (error) {
                resultDiv.textContent = `Error: ${error.message}`;
            }
        } else {
            resultDiv.textContent = 'Please enter a lambda expression';
        }
    });

    expressionInput.addEventListener('keypress', (event) => {
        if (event.key === 'Enter') {
            evaluateBtn.click();
        }
    });
});
