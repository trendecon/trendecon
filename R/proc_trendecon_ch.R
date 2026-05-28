#' Calculate Trendecon Main Indices for Switzerland
#'
#' Updates every Swiss index from Google Trends and copies the seasonally
#' adjusted series into `data/ch`. Indices are processed independently, so a
#' failure in one does not prevent the others from updating. See
#' [proc_trendecon()] for details.
#'
#' @param backfill_from Optional start date (`YYYY-mm-dd`). If supplied, each
#'   keyword's daily series is backfilled from this date before the regular
#'   update, to repair a gap left by an outage. Use once, then omit.
#' @return Invisibly, a per-index status data frame.
#' @export
proc_trendecon_ch <- function(backfill_from = NULL) {

  indices <- list(
    inflationrate = c(
      "inflation",
      "preise",
      "benzinpreis",
      "mietzins"
    ),
    clothing = c(
      "Mango",
      "Zara",
      "H&M",
      "PKZ",
      "Blue Tomato",
      "Dosenbach",
      "Schuhe kaufen",
      "Ochsner Schuhe"
    ),
    garden = c(
      "Heim+Hobby",
      "Bau+Hobby",
      "Do it + Garden",
      "Do it Migros",
      "Jumbo",
      "Landi",
      "Gartencenter",
      "Bauhaus",
      "Hornbach"
    ),
    luxury = c(
      "christ",
      "bucherer",
      "uhren",
      "uhr",
      "swarovski",
      "rhomberg",
      "juwelier"
    ),
    mobility = c(
      "Fahrplan",
      "taxi",
      "sixt",
      "google maps"
    ),
    social = c(
      "Kino",
      "Theater",
      "Cinema",
      "ticketcorner",
      "starticket",
      "oper",
      "konzert"
    ),
    # unicode codes
    # https://resources.german.lsa.umich.edu/schreiben/unicode/
    travel = c(
      "städtetrip",
      "flug buchen",
      "günstige flüge"
    ),
    trendecon = c(
      "Wirtschaftskrise",
      "Kurzarbeit",
      "arbeitslos",
      "Insolvenz"
    ),
    fooddelivery = c(
      "take away",
      "takeaway",
      "pizza bestellen",
      "dieci pizza"
    ),
    homeoffice = c(
      "headset",
      "monitor",
      "maus",
      "hdmi"
    )
  )

  proc_trendecon("CH", indices, backfill_from = backfill_from)
}
