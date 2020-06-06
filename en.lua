local CATEGORY_EX_ICES = {
  "codex", "murex", "silex", "vertex", "index"
}

local CATEGORY_IX_ICES = {
  "matrix", "radix", "helix"
}

local CATEGORY_UM_A = {
  "baterium", "agendum", "desideratum", "erratum", "stratum", "datum", "ovum",
  "extremum", "candelabrum"
}

local CATEGORY_US_I = {
  "alumnus", "alveolus", "bacillus", "bronchus", "locus", "nucleus", "stimulus",
  "meniscus", "thesaurus"
}

local CATEGORY_ON_A = {
  "criterion", "perihelion", "aphelion", "phenomenon", "prolegomenon",
  "noumenon", "organon", "asyndeton", "hyperbaton"
}

local CATEGORY_A_AE = {
  "alumna", "alga", "vertebra", "persona"
}

local CATEGORY_O_OS = {
  "albino", "archipelago", "armadillo", "commando", "crescendo", "fiasco",
  "ditto", "dynamo", "embryo", "ghetto", "guano", "inferno", "jumbo", "lumbago",
  "magneto", "manifesto", "medico", "octavo", "photo", "pro", "quarto", "canto",
  "lingo", "generalissimo", "stylo", "rhino", "casino", "auto", "macro", "zero",
  "todo"
}

local CATEGORY_O_I = {
  "solo", "soprano", "basso", "alto", "contralto", "tempo", "piano", "virtuoso"
}

local CATEGORY_EN_INA = {
  "stamen", "foramen", "lumen"
}

local CATEGORY_A_ATA = {
  "anathema", "enema", "oedema", "bema", "enigma", "sarcoma", "carcinoma",
  "gumma", "schema", "charisma", "lemma", "soma", "diploma", "lymphoma",
  "stigma", "dogma", "magma", "stoma", "drama", "melisma", "trauma", "edema",
  "miasma"
}

local CATEGORY_IS_IDES = {
  "iris", "clitoris"
}

local CATEGORY_US_US = {
  "apparatus", "impetus", "prospectus", "cantus", "nexus", "sinus", "coitus",
  "plexus", "status", "hiatus"
}

local CATEGORY_NONE_I = {
  "afreet", "afrit", "efreet"
}

local CATEGORY_NONE_IM = {
  "cherub", "goy", "seraph"
}

local CATEGORY_EX_EXES = {
  "apex", "latex", "cortex", "pontifex", "vortex", "simplex"
}

local CATEGORY_IX_IXES = {
  "appendix"
}

local CATEGORY_S_ES = {
  "acropolis", "chaos", "lens", "aegis", "cosmos", "mantis", "alias", "dais",
  "marquis", "asbestos", "digitalis", "metropolis", "atlas", "epidermis",
  "pathos", "bathos", "ethos", "pelvis", "bias", "gas", "polis", "caddis",
  "glottis", "rhinoceros", "cannabis", "glottis", "sassafras", "canvas", "ibis",
  "trellis"
}

local CATEGORY_MAN_MANS = {
  "human", "Alabaman", "Bahaman", "Burman", "German", "Hiroshiman", "Liman",
  "Nakayaman", "Oklahoman", "Panaman", "Selman", "Sonaman", "Tacoman",
  "Yakiman", "Yokohaman", "Yuman"
}

local uncountable = {
  --endings
  "fish", "ois", "sheep", "deer", "pox", "itis",

  -- words
  "bison", "flounder", "pliers", "bream", "gallows", "proceedings", "breeches",
  "graffiti", "rabies", "britches", "headquarters", "salmon", "carp", "herpes",
  "scissors", "chassis", "high-jinks", "sea-bass", "clippers", "homework",
  "series", "cod", "innings", "shears", "contretemps", "jackanapes", "species",
  "corps", "mackerel", "swine", "debris", "measles", "trout", "diabetes",
  "mews", "tuna", "djinn", "mumps", "whiting", "eland", "news", "wildebeest",
  "elk", "pincers", "sugar"
}

local irregular = {
  child = "children",
  ephemeris = "ephemerides",
  mongoose = "mongoose",
  mythos = "mythoi",
  ox = "oxen",
  soliloquy = "soliloquies",
  trilby = "trilbys",
  genus = "genera",
  quiz = "quizzes",
  beef = "beefs",
  brother = "brothers",
  cow = "cows",
  genie = "genies",
  money = "moneys",
  octopus = "octopuses",
  opus = "opuses"
}

local function contains(t, word)
  for i, v in ipairs(t) do
    if v == word then
      return true
    end
  end

  return false
end

local function endsWith(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

local function inflector(mode)
  local rules = {}

  local function rule(singular, plural)
    local rulefunc = function(word)
      local s = singular .. "$"
      if string.find(word, s) then
        return string.gsub(word, s, plural)
      end

      return nil
    end

    table.insert(rules, rulefunc)
  end

  local function categoryRule(list, singular, plural)
    local rulefunc = function(word)
      lword = string.lower(word)
      for i, suffix in ipairs(list) do
        if endsWith(lword, suffix) then
          if not endsWith(lword, singular) then
            error("Internal error!")
          end

          return string.gsub(word, singular .. "$", plural)
        end
      end
    end

    table.insert(rules, rulefunc)
  end

  categoryRule(uncountable, "", "")
  categoryRule(CATEGORY_MAN_MANS, "", "s")

  -- Handle irregular inflections for common suffixes
  rule("man", "men")
  rule("([lm])ouse", "%1ice")
  rule("tooth", "teeth")
  rule("goose", "geese")
  rule("foot", "feet")
  rule("zoon", "zoa")
  rule("([csx])is", "%1es")

  -- Handle fully assimilated classical inflections
  categoryRule(CATEGORY_EX_ICES, "ex", "ices")
  categoryRule(CATEGORY_IX_ICES, "ix", "ices")
  categoryRule(CATEGORY_UM_A, "um", "a")
  categoryRule(CATEGORY_ON_A, "on", "a")
  categoryRule(CATEGORY_A_AE, "a", "ae")

  categoryRule(CATEGORY_EN_INA, "en", "ina")
  categoryRule(CATEGORY_A_ATA, "a", "ata")
  categoryRule(CATEGORY_IS_IDES, "is", "ides")
  categoryRule(CATEGORY_US_US, "", "")
  categoryRule(CATEGORY_O_I, "o", "i")
  categoryRule(CATEGORY_NONE_I, "", "i")
  categoryRule(CATEGORY_NONE_IM, "", "im")
  categoryRule(CATEGORY_EX_EXES, "ex", "ices")
  categoryRule(CATEGORY_IX_IXES, "ix", "ices")

  categoryRule(CATEGORY_US_I, "us", "i")
  rule("([cs]h)", "%1es")
  rule("([zx])", "%1es")
  categoryRule(CATEGORY_S_ES, "", "es")
  categoryRule(CATEGORY_IS_IDES, "", "es")
  categoryRule(CATEGORY_US_US, "", "es")
  rule("(us)", "%1es")
  categoryRule(CATEGORY_A_ATA, "", "s")

  -- churches and such
  rule("([cs])h", "%1hes")
  rule("ss", "sses")

  --wolves and wives
  rule("([aeo]l)f", "%1ves")
  rule("(ar)f", "%1ves")
  rule("([nlw]i)fe", "%1ves")

  -- families and rays
  rule("([aeiou])y", "%1ys")
  rule("y", "ies")

  categoryRule(CATEGORY_O_I, "o", "os")
  categoryRule(CATEGORY_O_OS, "o", "os")
  rule("([aeiou])o", "%1os")
  rule("o", "oes")

  rule("ulum", "ula")

  categoryRule(CATEGORY_A_ATA, "", "es")

  rule("s", "ses")
  rule("", "s")

  return function(word, count)
    if count == 1 then
      return word
    end

    for i, rule in ipairs(rules) do
      result = rule(word)
      if result then return result end
    end

    return nil
  end
end

return inflector
