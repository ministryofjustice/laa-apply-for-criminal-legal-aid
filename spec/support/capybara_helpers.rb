module CapybaraHelpers
  def fill_in_date(date)
    fill_in('Day', with: date.mday)
    fill_in('Month', with: date.month)
    fill_in('Year', with: date.year)
  end

  def fill_date(question, with: nil)
    date = with || Time.zone.today

    within(find('legend', text: question).sibling('div.govuk-date-input')) do
      fill_in_date(date)
    end
  end

  # radio buttons
  def choose_answer(question, choice)
    q = find('legend', text: question).sibling('div.govuk-radios')

    within q do
      choose(choice)
    end
  end

  def choose_answer_all(question, choice)
    all('legend', text: question).each do |legend|
      within legend.sibling('div.govuk-radios') do
        choose(choice)
      end
    end
  end

  # check boxes
  def choose_answers(question, choices = [])
    q = page.find('legend', text: question).sibling('div.govuk-checkboxes')

    within q do
      choices.each do |choice|
        check(choice)
      end
    end
  end

  def save_and_continue
    click_button('Save and continue')
  end

  def summary_card(card_title)
    title = page.find(
      :xpath,
      "//h2[@class='govuk-summary-card__title' and text()='#{card_title}']"
    )

    title.ancestor('div.govuk-summary-card')
  end

  def within_card(card_title, &block)
    within(summary_card(card_title), &block)
  end
end
