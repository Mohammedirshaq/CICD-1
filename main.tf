provider "google" {
  project = "sam-452209"
}

resource "google_compute_instance" "terrainstancesai" {
  count = 2 
  name = "terra-${count.index + 1}"
  zone             = "us-central1-c"
  machine_type     = "e2-medium"
  

  boot_disk {
    initialize_params {
      image = "centos-stream-9"
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"
 access_config {

 }                                  #assign external IP

}
}
