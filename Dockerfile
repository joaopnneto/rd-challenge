FROM ruby:2.6.10-alpine
WORKDIR /challenge-rd/ruby
COPY . .
RUN gem install minitest
CMD ["ruby", "customer_success_balancing.rb"]