import places from 'places.js';

const initAutocomplete = (elementId) => {
  const addressInput = document.getElementById(elementId);
  if (addressInput) {
    places({ container: addressInput });
  }
};

export { initAutocomplete };
