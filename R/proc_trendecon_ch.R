#' Calculate Trendecon Main Indices for Switzeland
#'
#' @export
#'
proc_trendecon_ch <- function() {

  kw_inflationrate <- c(
    "inflation",
    "preise",
    "benzinpreis",
    "mietzins"
  )

  kw_clothing <- c(
    "Mango",
    "Zara",
    "H&M",
    "PKZ",
    "Blue Tomato",
    "Dosenbach",
    "Schuhe kaufen",
    "Ochsner Schuhe"
  )

  kw_fooddelivery <- c(
    "take away",
    "takeaway",
    "pizza bestellen",
    "dieci pizza"
  )

  kw_garden <- c(
    "Heim+Hobby",
    "Bau+Hobby",
    "Do it + Garden",
    "Do it Migros",
    "Jumbo",
    "Landi",
    "Gartencenter",
    "Bauhaus",
    "Hornbach"
  )

  kw_luxury <- c(
    "christ",
    "bucherer",
    "uhren",
    "uhr",
    "swarovski",
    "rhomberg",
    "juwelier"
  )

  kw_mobility <- c(
    "Fahrplan",
    "taxi",
    "sixt",
    "google maps"
  )


  kw_social <- c(
    "Kino",
    "Theater",
    "Cinema",
    "ticketcorner",
    "starticket",
    "oper",
    "konzert"
  )

  # unicode codes
  # https://resources.german.lsa.umich.edu/schreiben/unicode/
  kw_travel <- c(
    "st\u00E4dtetrip",
    "flug buchen",
    "g\u00FCnstige fl\u00FCge"
  )

  kw_homeoffice <- c(
    "headset",
    "monitor",
    "maus",
    "hdmi"
  )

  kw_trendecon <- c(
    "Wirtschaftskrise",
    "Kurzarbeit",
    "arbeitslos",
    "Insolvenz"
  )


  proc_index(kw_inflationrate, "CH", 'inflationrate')
  proc_index(kw_clothing, "CH", 'clothing')
  proc_index(kw_garden, "CH", 'garden')
  proc_index(kw_luxury, "CH", 'luxury')
  proc_index(kw_mobility, "CH", 'mobility')
  proc_index(kw_social, "CH", 'social')
  proc_index(kw_travel, "CH", 'travel')
  proc_index(kw_trendecon, "CH", 'trendecon')
  proc_index(kw_fooddelivery, "CH", 'fooddelivery')
  proc_index(kw_homeoffice, "CH", 'homeoffice')


  indices_in_production <- c(
    "inflationrate",
    "clothing",
    "garden",
    "luxury",
    "mobility",
    "social",
    "travel",
    "trendecon",
    "fooddelivery",
    "homeoffice"
  )

  # copy to data/ch
  lapply(indices_in_production, function(e) fs::file_copy(path_keyword(e, "ch", "sa"), path_data("ch"), overwrite = TRUE))

  # FIXME: also store d, w, m, f in data/ch

}
