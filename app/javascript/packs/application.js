import "bootstrap";
import { initAutocomplete } from "../plugins/init_autocomplete";
import { init_plant_dragging, init_ineractjs } from "../plugins/init_plant_dragging";
import "../plugins/flatpickr";

// set autocomplete on garden address field if it exists
initAutocomplete('garden_address');

// setup initial plant plot with dragging
init_plant_dragging();
