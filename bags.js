document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('.add-to-cart').forEach(button => {
    button.addEventListener('click', () => {
      const product = button.dataset.product || 'item';
      button.textContent = 'Added ✓';
      button.disabled = true;
      setTimeout(() => {
        button.textContent = 'Add to Cart';
        button.disabled = false;
      }, 1200);
      alert(`${product} added to your cart!`);
    });
  });

  const form = document.getElementById('bagContactForm');
  if (form) {
    form.addEventListener('submit', event => {
      event.preventDefault();
      const data = new FormData(form);
      const name = data.get('name').trim();
      const email = data.get('email').trim();
      const message = data.get('message').trim();
      if (!name || !email || !message) {
        alert('Please fill in all fields.');
        return;
      }
      alert(`Thanks, ${name}! We will reply to ${email} soon.`);
      form.reset();
    });
  }
});