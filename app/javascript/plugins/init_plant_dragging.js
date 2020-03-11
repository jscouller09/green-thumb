import interact from 'interactjs';

// for axaj requests
var xhttp = new XMLHttpRequest();
var csrfToken = document.querySelector('meta[name="csrf-token"]').content;

// setup global grid vars
var plants_container = document.getElementById('plot-container');
if (plants_container) {
  // global object with all plant info
  var plants = JSON.parse(plants_container.dataset.plants);
  // containers above plot area
  var wheelbarrow = document.getElementById('wheelbarrow');
  var plant_list = document.getElementById('plant-list');
  // determine grid spacing based of viewport size and plot size
  const intViewportHeight = window.innerHeight;
  // var intViewportWidth = window.innerWidth * 0.9;
  const page_container = document.querySelector('.container');
  const intViewportWidth = page_container.clientWidth * 0.95;
  const length = parseInt(plants_container.dataset.length);
  const width = parseInt(plants_container.dataset.width);
  // set the grid scale (i.e. each grid cell is how many mm?
  var grid_cell_mm = parseInt(plants_container.dataset.grid);;
  // work out how many rows and columns we want in the grid
  var grid_rows =  length / grid_cell_mm;
  var grid_cols = width / grid_cell_mm;
  // work out scaling factors
  var mm_per_pixel = width / intViewportWidth;
  var grid_size = intViewportWidth / grid_cols;
  // console.log(grid_rows, grid_cols, mm_per_pixel, grid_size);
  // set container style and dimensions
  plants_container.style.height = `${length / mm_per_pixel}px`;
  plants_container.style.width = `${width / mm_per_pixel}px`;
}

const update_plant_counts=(plant_counts=null, plant_icons=null) => {
  if (plant_list) {
    if (plant_counts == null) {
      plant_counts=JSON.parse(plant_list.dataset.plant_counts);
    }
    if (plant_icons == null) {
      plant_icons=JSON.parse(plant_list.dataset.plant_icons)
    }

    // update the UL with the count of each plant type
    plant_list.innerHTML = "";
    // make a new list entry with the count and icon for each plant type
    Object.keys(plant_counts).forEach(plant_type => {
      let list_element = document.createElement('li');
      let p_element = document.createElement('p');
      let icon_element = document.createElement('div');
      p_element.innerText = `${plant_type} (${plant_counts[plant_type]})`;
      icon_element.style.backgroundImage = `url("${plant_icons[plant_type]}")`;
      list_element.appendChild(icon_element);
      list_element.appendChild(p_element);
      plant_list.appendChild(list_element);
    });
  }
}

const error_modal=(error_msg) => {
  // set the body of the modal
  const modal_body = document.getElementById('error-modal-body');
  const modal_title = document.getElementById('error-modal-title');
  modal_title.innerText = "Whoops!"
  modal_body.innerHTML = "";
  const modal_content = document.createElement('p');
  modal_content.innerText = error_msg;
  modal_body.appendChild(modal_content);
  // trigger modal
  const modal_btn = document.getElementById('error-modal-button');
  modal_btn.click();
}

const info_modal=(modal_content, title_text) => {
  // set the body of the modal
  const modal_body = document.getElementById('error-modal-body');
  const modal_title = document.getElementById('error-modal-title');
  modal_title.innerHTML = title_text;
  modal_body.innerHTML = "";
  modal_body.appendChild(modal_content);
  // trigger modal
  const modal_btn = document.getElementById('error-modal-button');
  modal_btn.click();
}

const plant_info_callback=(target) => {
  const plant = plants[target.dataset.id];
  // make container div for content
  const content = document.createElement('div');

  // plant type
  const title = document.createElement('h5');
  title.innerHTML = `${plant.plant_type}&nbsp;`;

  // Add delete link using following html attribs...
  //  'data-confirm="Are you sure you want to remove this plant?" rel="nofollow" data-method="delete" href="/plants/1"'
  let element = document.createElement('a');
  element.classList.add('plot-plant-delete');
  element.setAttribute('data-confirm', "Are you sure you want to remove this plant?");
  element.setAttribute('rel', "nofollow");
  element.setAttribute('data-method', "delete");
  element.setAttribute('href', `/plants/${plant.id}`);
  element.innerHTML= `<i class="fas fa-trash"></i>`;
  title.appendChild(element);
  content.appendChild(title);

  // plant date and planted status
  element = document.createElement('p');
  if (plant.planted) {
    element.innerText = `Planted on ${plant.plant_date}.`;
  } else {
    element.innerText = `Scheduled for planting on ${plant.plant_date}.`;
  }
  content.appendChild(element);

  // pass to modal
  info_modal(content, "Plant details");
}

const watering_info_callback=(target) => {
  const plant = plants[target.dataset.id];
  // make container div for content
  const content = document.createElement('div');

  // plant type
  const title = document.createElement('h5');
  title.innerHTML = `${plant.plant_type}&nbsp;`;
  content.appendChild(title);

  // plant date and planted status
  let element = document.createElement('p');
  const age_days = Math.floor((Date.now() - Date.parse(plant.plant_date)) / 86400000);
  element.innerText = `Plant is ${age_days} days old (planted on ${plant.plant_date}). Needs ${plant.watering} L water.`;
  content.appendChild(element);

  // button to mark watering complete
  element = document.createElement('a');
  element.setAttribute('data-confirm-modal', "Have you really watered it?");
  element.setAttribute('rel', "nofollow");
  element.setAttribute('data-method', "patch");
  element.setAttribute('href', `/waterings/${plant.id}/complete`);
  element.innerHTML= `Done?`;
  content.appendChild(element);

  // pass to modal
  info_modal(content, "Watering requirements");
}


const add_plant_to_plot=(plant) => {
  // generate a plant div with a nested thumbnail image
  const plant_div = document.createElement('div');
  const thumbnail = document.createElement('div');
  const plant_border = document.createElement('div');

  // set plant div id and css properties
  plant_div.classList.add('plot-plant');
  plant_div.dataset.id = plant.id;
  plant_div.style.width = `${plant.radius_mm * 2 / mm_per_pixel}px`;
  plant_div.style.height = `${plant.radius_mm * 2 / mm_per_pixel}px`;

  // style plant border
  plant_border.classList.add('plot-plant-border');

  // style thumbnail image
  thumbnail.classList.add('plot-plant-thumbnail');
  if (plant.planted && plant.watering == null) {
    thumbnail.classList.add('planted');
  } else if (plant.watering > 0) {
    thumbnail.classList.add('needs-water');
  }
  // thumbnail.style.backgroundImage = `url("https://res.cloudinary.com/dm6mj1qp1/image/upload/v1583325509/${plant.photo_url}")`;
  thumbnail.style.backgroundImage = `url("${plant.icon}")`;

  // add event listener for double click on icon
  thumbnail.addEventListener('dblclick', (event) => {
    // want to operate on parent div of thumbnail icon that was clicked
    if (plant.watering == null) {
      // plot show page - double clicking should show plant info
      plant_info_callback(event.currentTarget.parentNode.parentNode);
    } else {
      // has watering info, so on watering dashboard
      // show watering info on double click
      watering_info_callback(event.currentTarget.parentNode.parentNode);
    }
  });

  // insert the thumbnail/border into the plant div
  plant_border.appendChild(thumbnail);
  plant_div.appendChild(plant_border);

  // insert the plant div into the plot container
  plants_container.appendChild(plant_div);

  return plant_div;
}

const init_ineractjs=(plant) => {
  // console.log(`Adding new plant id:${plant.id} type:${plant.plant_type} x:${plant.x} y:${plant.y}`);
  // create plant element
  const element = add_plant_to_plot(plant);

  // set wheelbarrow dimensions based on any unplaced plants (negative coordinates)
  if (wheelbarrow && ((plant.y < 0 || plant.y == null) || (plant.x < 0 || plant.x == null))) {
    wheelbarrow.innerHTML = "Drag the plant onto the plot or choose another plant";
    // plant dimensions
    let plant_size = 2*plant.radius_mm/mm_per_pixel;
    // plant is in the wheelbarrow, resize it if necessary to fit the plant
    let current_height = wheelbarrow.clientHeight;
    let current_width = wheelbarrow.clientWidth;
    if (current_height < plant_size) {
      wheelbarrow.style.height = `${plant_size}px`;
      current_height = plant_size;
    }
    if (current_width < plant_size) {
      wheelbarrow.style.width = `${plant_size}px`;
      current_width = plant_size;
    }
    // position plant in center of wheelbarrow area
    plant.y = Math.round(-current_height/grid_size);
    // console.log(grid_size, grid_cols, plant_size/grid_size, Math.round(current_width/2/grid_size));
    let wb_width = current_width/grid_size
    plant.x = Math.round(grid_cols - wb_width + (plant_size/grid_size));
  }

  // store inital positions
  plant.initial_x = plant.x
  plant.initial_y = plant.y
  // update global plants object also
  plants[plant.id] = plant

  let x = plant.x * grid_size;
  let y = plant.y * grid_size;
  element.style.transform = 'translate(' + x + 'px, ' + y + 'px)';
  if (!plant.planted && plant.watering == null) {
    interact(element)
      .draggable({
        modifiers: [
          interact.modifiers.snap({
            targets: [
              interact.createSnapGrid({ x: grid_size, y: grid_size })
            ],
            range: Infinity,
            relativePoints: [ { x: 0, y: 0 } ]
          }),
          interact.modifiers.restrict({
            restriction: element.parentNode,
            elementRect: { top: 0, left: 0, bottom: 1, right: 1 },
            endOnly: true
          })
        ],
        inertia: true,
        listeners: {
          end: (event) => {
            // console.log(event.currentTarget.dataset.id, plant.x, plant.y, x, y);

            // send x and y with fetch
            const url = `/plants/${element.dataset.id}`
            fetch(url, { method: "PATCH",
                         headers: { 'Content-Type': 'application/json',
                                    'x-csrf-token': csrfToken },
                         body: JSON.stringify(plant),
                        })
              .then(res => res.json())
              .then((data) => {
                if (data.accepted) {
                  // if response ok, keep updated plant x/y
                  console.log(`plant ${plant.id} moved to x:${plant.x} y:${plant.y}`);
                  // update global plants object also
                  plants[plant.id] = plant
                  // if the plant moved was a new one, add a copy to the wheelbarrow area
                  if (plant.initial_y < 0 && wheelbarrow && plant_list) {
                    console.log("Adding new plant...");
                    // create a new plant the same as this one
                    // also update the list of plants in the garden
                    let copy_plant = plant;
                    copy_plant.x = plant.initial_x;
                    copy_plant.y = plant.initial_y;
                    fetch("/plants", { method: "POST",
                                       headers: { 'Content-Type': 'application/json',
                                                 'x-csrf-token': csrfToken },
                                       body: JSON.stringify(copy_plant),
                                      })
                      .then(res => res.json())
                      .then(data => {
                        // update plant counts in the garden
                        update_plant_counts(data.plant_counts, data.plant_icons);
                        // attach the interact plugin to the duplicated plant
                        init_ineractjs(data.plant);
                      });
                  }
                } else {
                  // move it back to where it was or the initial position
                  (data.x == null) ? plant.x = plant.initial_x : plant.x = data.x;
                  (data.y == null) ? plant.y = plant.initial_y : plant.y = data.y;
                  x = plant.x * grid_size;
                  y = plant.y * grid_size;
                  event.target.style.transform = 'translate(' + x + 'px, ' + y + 'px)'
                  // update global plants object also
                  plants[plant.id] = plant
                  // modal error msg
                  error_modal(data.errors.base[0]);
                }
              })
          }
        }
      })
      .on('dragmove', function (event) {
        // update plant position (in number of grid cells, not pixels)
        plant.x += Math.round((event.dx / grid_size))
        plant.y += Math.round((event.dy / grid_size))
        // make sure current position matches what is in plant
        x = plant.x * grid_size;
        y = plant.y * grid_size;
        event.target.style.transform = 'translate(' + x + 'px, ' + y + 'px)'
      })
  }
}



const init_plant_dragging=() => {
  // check if we have a plant plot on the page
  const plants_container = document.getElementById('plot-container');
  if (plants_container) {
    // render the counts of different types of plants in the overview
    update_plant_counts();
    // first destroy any children already in the plot
    plants_container.innerHTML = "";
    // now go through each plant and add it to the plot
    Object.values(plants).forEach((plant) => {
      // attach the interact plugin to the plant
      init_ineractjs(plant);
    });
  }
}

export { init_plant_dragging };
