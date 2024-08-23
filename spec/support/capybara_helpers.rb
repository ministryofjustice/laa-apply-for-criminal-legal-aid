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

  # check boxes
  def choose_answers(question, choices = [])
    q = find('legend', text: question).sibling('div.govuk-checkboxes')

    within q do
      choices.each do |choice|
        check(choice)
      end
    end
  end

  def save_and_continue
    click_button('Save and continue')
  end
end
