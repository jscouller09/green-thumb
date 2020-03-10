import "bootstrap";
import { initAutocomplete } from "../plugins/init_autocomplete";
import { init_plant_dragging } from "../plugins/init_plant_dragging";
import "../plugins/flatpickr"
import { initMarquee } from "../plugins/marquee" ;
// set autocomplete on garden address field if it exists
initAutocomplete('garden_address');

// setup initial plant plot with dragging
init_plant_dragging();

// make sure we update plot layout on window resize
//window.addEventListener('resize', setup_plant_plot);
initMarquee();
