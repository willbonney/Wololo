// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";

// *****
// *****
// *****
import Chart from "chart.js/auto";

let hooks = {};
hooks.ChartJS = {
  mounted() {
    const ctx = this.el;
    console.log("ctx", ctx);
    const data = {
      type: "doughnut",
      data: {
        datasets: [
          {
            data: [],
            backgroundColor: [
              "#FFC107", // Amber
              "#2196F3", // Blue
              "#009688", // Teal
              "#4CAF50", // Green
              "#FF9800", // Orange
              "#9C27B0", // Purple
              "#F44336", // Red
              "#03A9F4", // Light Blue
              "#8BC34A", // Light Green
              "#FF69B4", // Pink
              "#3F51B5", // Indigo
              "#795548", // Brown
            ],
          },
        ],
        hoverOffset: 4,
        borderJoinStyle: "bevel",
      },
      options: {
        responsive: true,
        plugins: {
          legend: {
            position: "top",
          },
          title: {
            display: true,
            text: "Opponents by Country",
          },
        },
      },
    };
    const chart = new Chart(ctx, data);
    this.handleEvent("update-player", (event) => {
      console.log("event", event);
      chart.data.datasets[0].data = Object.values(event.byCountry);
      chart.data.labels = Object.keys(event.byCountry);
      chart.update();
    });
  },
  beforeUnmount() {
    this.handleEvent("update-player", null);
  },
};

// *****
// *****
// *****

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: hooks,
});
// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

//.from https://medium.com/@lionel.aimerie/integrating-chart-js-into-elixir-phoenix-for-visual-impact-9a3991f0690f
