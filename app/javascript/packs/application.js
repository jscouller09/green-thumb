import "bootstrap";
import { initAutocomplete } from "../plugins/init_autocomplete";
import { init_ineractjs } from "../plugins/init_ineractjs";

// set autocomplete on garden address field if it exists
initAutocomplete('garden_address');

// check if we have a plant plot on the page
const plants_container = document.getElementById('plot-container');
if (plants_container) {
  // determine grid spacing based of viewport size and plot size
  const intViewportHeight = window.innerHeight *.95;
  const intViewportWidth = window.innerWidth *.95;
  const length = parseInt(plants_container.dataset.length);
  const width = parseInt(plants_container.dataset.width);
  const mm_per_pixel = Math.max(length, width)/Math.max(intViewportHeight, intViewportWidth);
  let reverse_xy = false;
  // set container style and dimensions
  if (intViewportHeight >= intViewportWidth) {
    // the browser is more landscape, make plot portrait
    plants_container.style.width = `${Math.min(length, width) / mm_per_pixel}px`;
    plants_container.style.height = `${Math.max(length, width) / mm_per_pixel}px`;
    reverse_xy = true;
  } else {
    // the browser is more portrait, make plot landscape
    plants_container.style.height = `${Math.min(length, width) / mm_per_pixel}px`;
    plants_container.style.width = `${Math.max(length, width) / mm_per_pixel}px`;
  }
  plants_container.style.position = 'relative';
  // get plant data and iterate
  const plants = JSON.parse(plants_container.dataset.plants);
  plants.forEach((plant) => {
    // attach the interact plugin to the plant, set grid snapping and scale
    init_ineractjs(plant, mm_per_pixel, 10, reverse_xy);
  });
}
