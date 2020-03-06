import "bootstrap";
import { initAutocomplete } from "../plugins/init_autocomplete";
import { init_ineractjs } from "../plugins/init_ineractjs";

// set autocomplete on garden address field if it exists
initAutocomplete('garden_address');




const setup_plant_plot=() => {
  // check if we have a plant plot on the page
  const plants_container = document.getElementById('plot-container');
  if (plants_container) {
    // first destroy any children already in the plot
    plants_container.innerHTML = "";
    // determine grid spacing based of viewport size and plot size
    const intViewportHeight = window.innerHeight *.95;
    const intViewportWidth = window.innerWidth *.95;
    const length = parseInt(plants_container.dataset.length);
    const width = parseInt(plants_container.dataset.width);
    const mm_per_pixel = width / intViewportWidth;
    console.log(mm_per_pixel);
    // set container style and dimensions
    plants_container.style.height = `${length / mm_per_pixel}px`;
    plants_container.style.width = `${width / mm_per_pixel}px`;
    plants_container.style.position = 'relative';
    // get plant data and iterate
    const plants = JSON.parse(plants_container.dataset.plants);
    plants.forEach((plant) => {
      // attach the interact plugin to the plant, set grid snapping and scale
      init_ineractjs(plant, mm_per_pixel, 100/mm_per_pixel);
    });
  }
}

setup_plant_plot();

// make sure we update plot layout on window resize
//window.addEventListener('resize', setup_plant_plot);
