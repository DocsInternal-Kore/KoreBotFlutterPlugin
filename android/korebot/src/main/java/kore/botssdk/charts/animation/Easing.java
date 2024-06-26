package kore.botssdk.charts.animation;

import android.animation.TimeInterpolator;

public class Easing {
    public static final  EasingFunction Linear = new  EasingFunction() {
        public float getInterpolation(float input) {
            return input;
        }
    };
    public static final  EasingFunction EaseInQuad = new  EasingFunction() {
        public float getInterpolation(float input) {
            return input * input;
        }
    };
    public static final  EasingFunction EaseOutQuad = new  EasingFunction() {
        public float getInterpolation(float input) {
            return -input * (input - 2.0F);
        }
    };
    public static final  EasingFunction EaseInOutQuad = new  EasingFunction() {
        public float getInterpolation(float input) {
            input *= 2.0F;
            return input < 1.0F ? 0.5F * input * input : -0.5F * (--input * (input - 2.0F) - 1.0F);
        }
    };
    public static final  EasingFunction EaseInCubic = new  EasingFunction() {
        public float getInterpolation(float input) {
            return (float)Math.pow(input, 3.0D);
        }
    };
    public static final  EasingFunction EaseOutCubic = new  EasingFunction() {
        public float getInterpolation(float input) {
            --input;
            return (float)Math.pow(input, 3.0D) + 1.0F;
        }
    };
    public static final  EasingFunction EaseInOutCubic = new  EasingFunction() {
        public float getInterpolation(float input) {
            input *= 2.0F;
            if (input < 1.0F) {
                return 0.5F * (float)Math.pow(input, 3.0D);
            } else {
                input -= 2.0F;
                return 0.5F * ((float)Math.pow(input, 3.0D) + 2.0F);
            }
        }
    };
    public static final  EasingFunction EaseInQuart = new  EasingFunction() {
        public float getInterpolation(float input) {
            return (float)Math.pow(input, 4.0D);
        }
    };
    public static final  EasingFunction EaseOutQuart = new  EasingFunction() {
        public float getInterpolation(float input) {
            --input;
            return -((float)Math.pow(input, 4.0D) - 1.0F);
        }
    };
    public static final  EasingFunction EaseInOutQuart = new  EasingFunction() {
        public float getInterpolation(float input) {
            input *= 2.0F;
            if (input < 1.0F) {
                return 0.5F * (float)Math.pow(input, 4.0D);
            } else {
                input -= 2.0F;
                return -0.5F * ((float)Math.pow(input, 4.0D) - 2.0F);
            }
        }
    };
    public static final  EasingFunction EaseInSine = new  EasingFunction() {
        public float getInterpolation(float input) {
            return -((float)Math.cos((double)input * 1.5707963267948966D)) + 1.0F;
        }
    };
    public static final  EasingFunction EaseOutSine = new  EasingFunction() {
        public float getInterpolation(float input) {
            return (float)Math.sin((double)input * 1.5707963267948966D);
        }
    };
    public static final  EasingFunction EaseInOutSine = new  EasingFunction() {
        public float getInterpolation(float input) {
            return -0.5F * ((float)Math.cos(3.141592653589793D * (double)input) - 1.0F);
        }
    };
    public static final  EasingFunction EaseInExpo = new  EasingFunction() {
        public float getInterpolation(float input) {
            return input == 0.0F ? 0.0F : (float)Math.pow(2.0D, 10.0F * (input - 1.0F));
        }
    };
    public static final  EasingFunction EaseOutExpo = new  EasingFunction() {
        public float getInterpolation(float input) {
            return input == 1.0F ? 1.0F : -((float)Math.pow(2.0D, -10.0F * (input + 1.0F)));
        }
    };
    public static final  EasingFunction EaseInOutExpo = new  EasingFunction() {
        public float getInterpolation(float input) {
            if (input == 0.0F) {
                return 0.0F;
            } else if (input == 1.0F) {
                return 1.0F;
            } else {
                input *= 2.0F;
                return input < 1.0F ? 0.5F * (float)Math.pow(2.0D, 10.0F * (input - 1.0F)) : 0.5F * (-((float)Math.pow(2.0D, -10.0F * --input)) + 2.0F);
            }
        }
    };
    public static final  EasingFunction EaseInCirc = new  EasingFunction() {
        public float getInterpolation(float input) {
            return -((float)Math.sqrt(1.0F - input * input) - 1.0F);
        }
    };
    public static final  EasingFunction EaseOutCirc = new  EasingFunction() {
        public float getInterpolation(float input) {
            --input;
            return (float)Math.sqrt(1.0F - input * input);
        }
    };
    public static final  EasingFunction EaseInOutCirc = new  EasingFunction() {
        public float getInterpolation(float input) {
            input *= 2.0F;
            return input < 1.0F ? -0.5F * ((float)Math.sqrt(1.0F - input * input) - 1.0F) : 0.5F * ((float)Math.sqrt(1.0F - (input -= 2.0F) * input) + 1.0F);
        }
    };
    public static final  EasingFunction EaseInElastic = new  EasingFunction() {
        public float getInterpolation(float input) {
            if (input == 0.0F) {
                return 0.0F;
            } else if (input == 1.0F) {
                return 1.0F;
            } else {
                float p = 0.3F;
                float s = p / 6.2831855F * (float)Math.asin(1.0D);
                return -((float)Math.pow(2.0D, 10.0F * --input) * (float)Math.sin((input - s) * 6.2831855F / p));
            }
        }
    };
    public static final  EasingFunction EaseOutElastic = new  EasingFunction() {
        public float getInterpolation(float input) {
            if (input == 0.0F) {
                return 0.0F;
            } else if (input == 1.0F) {
                return 1.0F;
            } else {
                float p = 0.3F;
                float s = p / 6.2831855F * (float)Math.asin(1.0D);
                return 1.0F + (float)Math.pow(2.0D, -10.0F * input) * (float)Math.sin((input - s) * 6.2831855F / p);
            }
        }
    };
    public static final  EasingFunction EaseInOutElastic = new  EasingFunction() {
        public float getInterpolation(float input) {
            if (input == 0.0F) {
                return 0.0F;
            } else {
                input *= 2.0F;
                if (input == 2.0F) {
                    return 1.0F;
                } else {
                    float p = 2.2222223F;
                    float s = 0.07161972F * (float)Math.asin(1.0D);
                    return input < 1.0F ? -0.5F * (float)Math.pow(2.0D, 10.0F * --input) * (float)Math.sin((input - s) * 6.2831855F * p) : 1.0F + 0.5F * (float)Math.pow(2.0D, -10.0F * --input) * (float)Math.sin((input - s) * 6.2831855F * p);
                }
            }
        }
    };
    public static final  EasingFunction EaseInBack = new  EasingFunction() {
        public float getInterpolation(float input) {
            float s = 1.70158F;
            return input * input * (2.70158F * input - 1.70158F);
        }
    };
    public static final  EasingFunction EaseOutBack = new  EasingFunction() {
        public float getInterpolation(float input) {
            float s = 1.70158F;
            --input;
            return input * input * (2.70158F * input + 1.70158F) + 1.0F;
        }
    };
    public static final  EasingFunction EaseInOutBack = new  EasingFunction() {
        public float getInterpolation(float input) {
            float s = 1.70158F;
            input *= 2.0F;
            return input < 1.0F ? 0.5F * input * input * (((s *= 1.525F) + 1.0F) * input - s) : 0.5F * ((input -= 2.0F) * input * (((s *= 1.525F) + 1.0F) * input + s) + 2.0F);
        }
    };
    public static final  EasingFunction EaseInBounce = new  EasingFunction() {
        public float getInterpolation(float input) {
            return 1.0F -  Easing.EaseOutBounce.getInterpolation(1.0F - input);
        }
    };
    public static final  EasingFunction EaseOutBounce = new  EasingFunction() {
        public float getInterpolation(float input) {
            float s = 7.5625F;
            if (input < 0.36363637F) {
                return s * input * input;
            } else if (input < 0.72727275F) {
                return s * (input -= 0.54545456F) * input + 0.75F;
            } else {
                return input < 0.90909094F ? s * (input -= 0.8181818F) * input + 0.9375F : s * (input -= 0.95454544F) * input + 0.984375F;
            }
        }
    };
    public static final  EasingFunction EaseInOutBounce = new  EasingFunction() {
        public float getInterpolation(float input) {
            return input < 0.5F ?  Easing.EaseInBounce.getInterpolation(input * 2.0F) * 0.5F :  Easing.EaseOutBounce.getInterpolation(input * 2.0F - 1.0F) * 0.5F + 0.5F;
        }
    };

    public Easing() {
    }

    public interface EasingFunction extends TimeInterpolator {
        float getInterpolation(float var1);
    }
}
